Raspberry Pi Motion Tracker
===========
Interfacing a Accelerometer and a Gyroscope with the Raspberry Pi.

These sensors are interfaced over the I2C bus. 

The project makes use of the HiPi Library.


Accelerometer---https://www.sparkfun.com/products/10955


Gyroscope-------http://www.pololu.com/catalog/product/2125


The Perl Script will detect the angle of orientation, the C code will plot the graph of the 1000 values of the angle, using GNU plot.


Webpage of the HiPi Library-http://raspberrypi.znix.com/hipidocs/mod_gpio_bcm2835_i2c.htm
NOTE: This Library is written for I2C devices that need a repeated start signal.


Steps to use this code:-

1. Install the HiPi Library. Run the folowing commands in the same order

   a. sudo apt-get upgrade

   b. wget http://raspberry.znix.com/hipifiles/hipi-install   
   
   c. perl hipi-install
  
    This will install Hi-Pi Library on your Raspberry Pi.

2. Now first run the Perl Script titled test.pl
   This can be done by typing the following command
   sudo perl test.pl    

   This script will initialize the sensors, and also take 1000 samples of each of the sensors.
   A txt file titled 'angle_data.txt' will be created automatically.

3. Now for plotting the graph do the following steps.
   
   a. First run the c_graph.c  C code.
      This can be done by typing the following command on the terminal
      gcc c_graph.c
   
   b. Now run the executable created. For this type the following command on the terminal
      ./a.out

   After this the graph should appear on the screen.
   
   NOTE: You should have gnuplot installed on your system. This can be done by typing the following commands
   
   a. sudo apt-get install gnuplot
   
   b. sudo apt-get install libwxgtk2.8-dev
   
   c. sudo apt-get libwxgtk2.8-dev
   
   d. sudo apt-get libreadline5-dev
   
   e. sudo apt-get libx11-dev
   
   f. sudo apt-get libxt-dev
   
   
   
   
   


      


