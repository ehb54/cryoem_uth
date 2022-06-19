# cryoem_uth

Run relion & cryosparc on LS6

## prerequisities

 * a valid account with available allocation on LS6
 * a valid cryosparc license id [get a cryosparc license](https://guide.cryosparc.com/setup-configuration-and-management/how-to-download-install-and-configure/obtaining-a-license-id)

## instructions

### setting up a session

 * start a vis session [here](https://vis.tacc.utexas.edu)
   * select:
     * System `Lonestar6`
     * Application `DCV remote desktop`
     * Project - this is the allocation which will be charged for the usage
     * Queue - `gpu-a100`
     * Nodes - the number of nodes
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
   
### working within the GUI window

#### first time usage
 * in the terminal window of the GUI
   * `git clone https://github.com/ehb54/cryoem_uth cryoem`
   * 
