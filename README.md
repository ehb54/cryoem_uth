# Run relion & cryosparc on LS6

Instructions and scripts to run relion & cryosparc on LS6

## prerequisities

 * a valid account with available allocation on LS6
 * a valid cryosparc license id [get a cryosparc license](https://guide.cryosparc.com/setup-configuration-and-management/how-to-download-install-and-configure/obtaining-a-license-id)
 * knowledge of transfering files to and from LS6
 * background on working with relion & cryosparc 

## instructions

### setting up a session

 * start a vis session [here](https://vis.tacc.utexas.edu)
   * select:
     * System `Lonestar6`
     * Application `DCV remote desktop`
     * Project - this is the allocation which will be charged for the usage
     * Queue - `gpu-a100`
     * Nodes - the number of nodes - currently only 1 node is supported
     * Job Name - optional, but useful if you are running multiple jobs
     * Time limit - Important - limits the maximum time of the session
     * Reservation - Ignore unless you have made special arrangements
     * VNC Desktop Resolution - should be disabled
   * e.g. (with Project not yet selected) ![image](https://user-images.githubusercontent.com/11505970/174486988-19b40c0f-3e6a-4164-a36b-86178313a34c.png)
   * Click `submit`
   * If all is well, you should be presented with a new `TAP Job Status` screen
   * e.g. ![image](https://user-images.githubusercontent.com/11505970/174487338-98713cfa-de26-4a61-a583-429c041b28c3.png)
   * Click `Connect`
   * A new screen will appear where you will need to enter your credentials (not shown)
   * Finally you will be presented (typically in a new tab) a window with the GUI desktop running on the allocated compute node
   * e.g. ![image](https://user-images.githubusercontent.com/11505970/174487501-b047b4af-979b-48d5-b921-89e0bd8c6116.png)
   * Properly *End your session* when you are done or you allocation will continue to be charged until the Time Limit you initially set expires
     * N.B. the window `END SESSION HERE` allows you to end the job within the GUI window
     * You can also switch to the Analysis Portal Tab and click `End Job`
 * Easy way after first job
   * At the bottom right of the TACC vis window are listed past jobs. You can click details to see details. Click `resubmit` to start a job again with previous settings
  
### working within the GUI window
 * commands below are in the terminal window of the GUI

#### first time usage
 * Install the helper tools in your home directory
  * `cd ~ && git clone https://github.com/ehb54/cryoem_uth cryoem`

#### running relion
 * make a new or change to previously existing Relion project directory
   * `relion_project_1` below is arbitrary, name it as you wish
   * make new
     * `mkdir $WORK/relion_project_1`
   * change to existing
     * `cd $WORK/relion_project_1` 
 * run relion
   * `~/cryoem/relion`
     * the first time usage:
       * it will take a few minutes while it downloads and installs - depends on the load on LS6 file systems and network
     * accepts standard relion command line arguments

#### running cryosparc
 * `~/cryoem/cryosparc`
   * first time usage:
     * make sure you have your cryosparc license available
     * you will need to enter various install information such as email, username, a new password, etc.
     * downloads & installs
     * it can take about 30 minutes or more to install depending on the load on LS6 file systems and network
   * always:
     * starts the server
     * starts the web browser
   * accepts standard cryosparcm command line arguments
     * start|stop|restart|status

### known issues
 * [issues](https://github.com/ehb54/cryoem_uth/issues)
   * report one here if you find one!

### default paths, ports
 * [configuration](https://github.com/ehb54/cryoem_uth/blob/main/config.json)
   * update the contents of this file if needed
