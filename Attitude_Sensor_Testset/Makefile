I2C_Test: I2C_Connection_Test.o Attitude_Sensor_Functions.o GPIO_Functions.o
	gcc -g -Wall Attitude_Sensor_Functions.o GPIO_Functions.o I2C_Connection_Test.o -o I2C_Test -l wiringPi

I2C_Connection_Test.o: I2C_Connection_Test.c I2C_Test.h
	gcc -g -Wall -c I2C_Connection_Test.c

Attitude_Sensor_Functions.o: Attitude_Sensor_Functions.c I2C_Test.h
	gcc -g -Wall -c Attitude_Sensor_Functions.c

GPIO_Functions.o: GPIO_Functions.c I2C_Test.h
	gcc -g -Wall -c GPIO_Functions.c

clean:
	rm -f I2C_Connection_Test.o GPIO_Functions.o Attitude_Sensor_Functions.o I2C_Test

run:
	clear
	sudo ./I2C_Test

all: clean I2C_Test
