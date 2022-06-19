# perl utility routines

die "$0: \$bdir is not defined\n" if !defined $bdir;

use JSON;
use File::stat;
use Cwd 'abs_path';

$| = 1;

# configfile
$configfile = "$bdir/config.json";

sub config_init {
    error_exit("$0: config_init() : $configfile does not exist or is not readable" ) if !-e $configfile || !-r $configfile;

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

    if ( exists $$config{debug} ) {
        $debug = $$config{debug};
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
    print "run_cmd(): command : $cmd\n" if $debug;
    $run_cmd_last_error = 0;
    $run_cmd_last_result = `$cmd`;
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

return true;

