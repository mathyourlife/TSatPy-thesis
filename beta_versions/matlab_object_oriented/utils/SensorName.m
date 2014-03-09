function strName = SensorName(intSensor)
% Input 1-14 and return the name of the sensor

switch intSensor
    case 1
        strName = 'CSS1';
    case 2
        strName = 'CSS2';
    case 3
        strName = 'CSS3';
    case 4
        strName = 'CSS4';
    case 5
        strName = 'CSS5';
    case 6
        strName = 'CSS6';
    case 7
        strName = 'AccelN1';
    case 8
        strName = 'AccelR1';
    case 9
        strName = 'AccelN2';
    case 10
        strName = 'AccelR2';
    case 11
        strName = 'Gyro';
    case 12
        strName = 'TAMX';
    case 13
        strName = 'TAMY';
    case 14
        strName = 'TAMZ';
end
