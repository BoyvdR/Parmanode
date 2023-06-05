# Parmanode 3.3.7

### Instructions to install at the end

## Introduction

For Mac (x86_64, M1/M2), Linux (x86_64, and Raspberry Pi 32 or 64 bit)

Parmanode is an automated installation wizard and menu for desktiop
computers, with the following software (list is growing):

                Bitcoin
                Electrum Server (Fulcrum)
                LND
                BTCPay 
                Docker
                Tor
                Mempool Space
                Sparrow Bitcoin Wallet
                Ride The Lightning Wallet
                Electrum Desktop Wallet
                Educational material by Parman

Parmanode is designed for non-technical users giving them the ability to 
download and verify Bitcoin related software, and sync using an external 
or internal drive, and also have configuration options presented to them
with automation. No manual configuration file editing will be required.

Users only need to read the menu options carefully, and respond to
the questions - no command line interaction is ever needed. For example, 
from a menu, bitcoin-cli commands are available, pruning can be activated 
and rpcuser/rpcpassword can also be set.

The software also comes with helpful information, including links to various
articles on my website, armantheparman.com, so that Bitcoiners keep learning
more about Bitcoin and how to be safely self-sovereign. Information on how 
to connect various wallets to the node is provided.

The most basic usage would be an internal drive to sync, running the latest
version of Bitcoin Core, and connecting Sparrow Bitcoin Wallet or Specter
Desktop Wallet directly to the node on the same computer.

While I tried to avoid it, for now, Mac users who wish to use Fulcrum will
need to run it in a Docker container. It has been made very easy, just 
follow the wizard menu options.

## DRIVE STRUCTURE 

Internal drive:
               
               /|--- $HOME ---|
                |             |--- .bitcoin                           (may or may not be a symlink)
                |             |--- .parmanode                         (config files)
                |             |--- .btcpayserver                      (config, mounted to docker container) 
                |             |--- .nbxplorer                         (config, mounted to docker container)
                |             |--- .lnd                               (lnd database)                          
                |             |--- .sparrow                           (confit and wallet files)
                |             |--- parmanode ---|
                |                               |--- bitcoin ------|  (keeps B core download and pgp stuff)
                |                               |
                |                               |--- fulcrum ------|  (keeps Fulcrum binary and config. Volume
                |                               |                      mounted for docker version)
                |                               |
                |                               |--- fulcrum_db ---|  (fulcrum databas)
                |                               |
                |                               |--- LND ----------|  (downloaded files) 
                |                               |
                |                               |--- mempool ------|  (downloaded files)
                |                               |                                        
                |                               |--- RTL ----------|  (config and database)
                |                               |                                        
                |                               |--- Sparrow ------|  (binary)
                |                               
                |--- media ---|
                |             |--- parmanode ---|                  
                |                               |--- .bitcoin ---|    (symlink target and ext drive mountpoint)
                |           
                |--- usr  --- |--- local  ------|--- bin ---|         (keeps bitcoin binary files)
                |
                |--- Docker conatainer (btcpay) ---|
                |                                  |---home/parman/parmanode/btcpayserver
                |                                  |---home/parman/parmanode/NBXplorer
                |                                                  
                |--- 3 Docker containers                              (mempool: api, web, db)
                |--- RTL Docker 

If an external drive is used, a symlink on the internal drive will point to the .bitcoin directory.

               /|--- .bitcoin ----|
                |--- fulcrum_db---|

## HOW TO RUN / INSTALL

Open the terminal application and type the following (and hit \<enter\> after each line.
Also, do note it is case sensitive):

    cd Desktop
    git clone http://github.com/armantheparman/parmanode.git
    cd parmanode
    ./run_parmanode.sh

If you don't like all that typing, copy and paste the following single line into terminal
and hit \<enter\>:

    cd Desktop && git clone http://github.com/armantheparman/parmanode.git && cd parmanode && ./run_parmanode.sh

From then on to run Parmanode, you can double click the run_parmanode.sh file. If you
get a popup, choose to "run in terminal". Alternatively you can open terminal, navigate to
the right directory with 
    
    cd Desktop/parmanode
    ./run_parmanode.sh

If you get a fingerprint error/warning when you run the git clone. That's fine, carry on.

This will add the program to your desktop and run the program.
You can move it but DO NOT move it to the home directory or really bad things will happen.

Actually, you can rename the directory from parmanode to anything else, then you could
move it anywhere. The reason this is mentioned is that Parmanode will create an application
directory called parmanode which lives in the home directory. This will create conflict
and file loss if you don't follow these instructions.

When the program runs, you will be asked at some point for a password - this is your 
computer's "sudo" or login password, and is necessary for Parmanode to access system 
functions like mounting drives.


## INSTRUCTIONS TO UPGRADE

If you have any version of Parmanode 2.x.x, going to version 3.x.x, you need to uninstall 
version 2 of Parmanode before installing version 3. You don't need to delete the Bitcoin 
blockchain.

Otherwise, use the parmanode menu to upgrade to the latest version.
You could also just type "git pull" from within the parmanode directory. Not the parmanode
application directory in the home menu, the parmanode directory on your desktop.
 
