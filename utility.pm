# perl utility routines

die "$0: \$bdir is not defined\n" if !defined $bdir;

use JSON;
use File::stat;
use Cwd 'abs_path';

$| = 1;

# configfile
$configfile = "$bdir/config.json";
# secrets
$secretsfile = "$bdir/.secrets.json";

sub secrets_init {
    if ( !-e $secretsfile ) {
        $secrets = decode_json( "{}" );
        return;
    }

    error_exit("$0: secrets_init() : $secretsfile is not readable" ) if !-r $secretsfile;

    ## check permissions
    {
        my $info = stat( $secretsfile );
        if ( $info->mode & 0077 ) {
            error_exit( "$0: permissions are too lenient on $secretsfile\nto fix:\nchmod 600 $secretsfile\n" );
        }
    }

    my @secretsdata = `cat $secretsfile`;

    error_exit( "$0: secrets_init(): $secretsfile empty" ) if @$secretsdata;

    grep s/#.*$//, @secretsdata;

    $secrets = decode_json( join '', @secretsdata ) || die "$0: $secretsfile error decoding\n";
}

sub secrets_write {
    my $json = JSON->new;
    my $fo = $secretsfile;
    open OUT, ">$fo" || error_exit( "$0: log_write() error trying write secrets $fo $!" );
    print OUT $json->pretty->encode( $secrets );
    print OUT "\n";
    close OUT;
}    

sub config_init {
    my $type = shift;
    error_exit("$0: config_init() : $configfile does not exist or is not readable" ) if !-e $configfile || !-r $configfile;

    error_exit("$0: config_init($type) : internal error - type must be relion or cryosparc") if $type !~ /^(relion|cryosparc)$/;
    
    ## check permissions
    {
        my $info = stat( $configfile );
        if ( $info->mode & 0077 ) {
            error_exit( "$0: permissions are too lenient on $configfile\nto fix:\nchmod 600 $configfile\n" );
        }
    }

    my @configdata = `cat $configfile`;

    error_exit( "$0: config_init(): $configfile empty" ) if @$configdata;

    grep s/#.*$//, @configdata;

    $config = decode_json( join '', @configdata ) || die "$0: $configfile error decoding\n";

    secrets_init();

    if ( exists $$config{debug} ) {
        $debug = $$config{debug};
    }

    if ( $type eq 'relion' ) {
        for my $req (
            "relion_version"
            ,"relion_docker"
            ,"sif_directory"
            ) {
            error_exit( "$0: config_init() : $configfile missing required definitions for $req" ) if !exists $$config{$req};
        }

        if ( $$config{sif_directory} =~ /^~\// ) {
            ## replace with HOME
            $$config{sif_directory} =~ s/^~/$ENV{HOME}/;
        }

        ## evaluate ENV vars in sif_directory

        $$config{sif_directory} =~ s/(\$ENV\{\w+\})/$1/eeg;

        if ( !-d $$config{sif_directory} ) {
            print "Making dirctory $$config{sif_directory}\n";
            `mkdir $$config{sif_directory}`;
            if ( !-d $$config{sif_directory} ) {
                error_exit( "could not make directory $$config{sif_directory}" );
            }
        }

        $$config{sif_directory} =~ abs_path($$config{sif_directory});
    }

    if ( $type eq 'cryosparc' ) {
        for my $req (
            "cryosparc_directory"
            ,"cryosparc_downloads"
            ,"cryosparc_cuda_path"
            ,"cryosparc_port"
            ) {
            error_exit( "$0: config_init() : $configfile missing required definitions for $req" ) if !exists $$config{$req};
        }

        if ( $$config{cryosparc_directory} =~ /^~\// ) {
            ## replace with HOME
            $$config{cryosparc_directory} =~ s/^~/$ENV{HOME}/;
        }

        ## evaluate ENV vars in cryosparc_directory

        $$config{cryosparc_directory} =~ s/(\$ENV\{\w+\})/$1/eeg;

        if ( !-d $$config{cryosparc_directory} ) {
            print "Making dirctory $$config{cryosparc_directory}\n";
            `mkdir $$config{cryosparc_directory}`;
            if ( !-d $$config{cryosparc_directory} ) {
                error_exit( "could not make directory $$config{cryosparc_directory}" );
            }
        }

        $$config{cryosparc_directory} =~ abs_path($$config{cryosparc_directory});

        if ( $$config{cryosparc_downloads} =~ /^~\// ) {
            ## replace with HOME
            $$config{cryosparc_downloads} =~ s/^~/$ENV{HOME}/;
        }

        ## evaluate ENV vars in cryosparc_downloads

        $$config{cryosparc_downloads} =~ s/(\$ENV\{\w+\})/$1/eeg;

        if ( !-d $$config{cryosparc_downloads} ) {
            print "Making dirctory $$config{cryosparc_downloads}\n";
            `mkdir $$config{cryosparc_downloads}`;
            if ( !-d $$config{cryosparc_downloads} ) {
                error_exit( "could not make downloads $$config{cryosparc_downloads}" );
            }
        }

        $$config{cryosparc_downloads} =~ abs_path($$config{cryosparc_downloads});
    }
}

$run_cmd_last_error;
$run_cmd_last_result;

sub singularity_run_cmd {
    my $cmd       = shift || die "run_cmd() requires an argument\n";
    my $no_die    = shift;
    my $repeattry = shift;

    $cmd = "bash -c \"module load tacc-singularity; $cmd\"";
    return run_cmd( $cmd, $no_die, $repeattry );
}

sub run_cmd {
    my $cmd       = shift || die "run_cmd() requires an argument\n";
    my $no_die    = shift;
    my $repeattry = shift;
    my $echo      = shift;
    print "run_cmd(): command : $cmd\n" if $debug;
    $run_cmd_last_error = 0;
    if ( $echo ) {
        print `$cmd`;
    } else {
        $run_cmd_last_result = `$cmd`;
    }
    chomp $run_cmd_last_result;
    print "run_cmd(): result : $run_cmd_last_result\n" if $debug;
    if ( $? ) {
        $run_cmd_last_error = $?;
        if ( $no_die ) {
            warn "run_cmd(\"$cmd\") returned $?\n";
            if ( $repeattry > 0 ) {
                warn "run_cmd(\"$cmd\") repeating failed command tries left = $repeattry )\n";
                return run_cmd( $cmd, $no_die, --$repeattry );
            }
        } else {
            error_exit( "run_cmd(\"$cmd\") returned $?" );
        }
    }
                
    return $run_cmd_last_result;
}

sub run_cmd_last_error {
    return $run_cmd_last_error;
}

sub error_exit {
    my $msg = shift;
    die "$msg\n";
}

sub debug_json {
    my $tag = shift;
    my $msg = shift;
    my $json = JSON->new; # ->allow_nonref;
    
    line()
        . "$tag\n"
        . line()
        . $json->pretty->encode( $$msg )
        . "\n"
        . line()
        ;
}

sub getinput {
    my $msg        = shift;
    my $allowempty = shift;
    # my $pwtype     = shift;

    my $input;
    do {
        print "$msg ";
        $input = <STDIN>;
        chomp $input;
    } while ( $allowempty || !length($input) );

    return $input;
}

sub getareyousure {
    my $msg    = shift;
    print "$msg\n";
    my $res;
    do {
        $res = getinput( "Are you sure? (yes or no)" );
        print "res is '$res'\n";
    } while ( lc($res) !~ /^(yes|no)$/ );
    return lc($res) eq 'yes';
}

sub line {
    my $char = shift;
    $char = '-' if !$char;
    ${char}x80 . "\n";
}

sub message_header {
    my $msg = shift;
    line() . "$msg\n" . line();
}

return true;

