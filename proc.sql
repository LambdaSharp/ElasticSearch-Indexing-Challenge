DROP PROCEDURE IF EXISTS LAMBDASHARP_proc;
DELIMITER ;;
CREATE PROCEDURE LAMBDASHARP_proc(
  IN op VARCHAR(20),
  IN id INT,
  IN name VARCHAR(255),
  IN urlslug varchar(4096),
  IN identity varchar(255),
  IN alignment varchar(255),
  IN eye_color varchar(255),
  IN hair_color varchar(255),
  IN sex varchar(255),
  IN gsm varchar(255),
  IN alive varchar(255),
  IN appearances int,
  IN first_appearance varchar(10),
  year int,
  lon double,
  lat double
) LANGUAGE SQL
BEGIN
CALL mysql.lambda_async(
  'LAMBDA_INDEXER_ARN',
  CONCAT(
    '{"name": "', name, '",',
     '"op": "', op, '",',
     '"id": "', id, '",',
     '"urlslug": "', urlslug, '",',
     '"identity": "', identity, '",',
     '"alignment": "', alignment, '",',
     '"eye_color": "', eye_color, '",',
     '"hair_color": "', hair_color, '",',
     '"sex": "', sex, '",',
     '"gsm": "', gsm, '",',
     '"alive": "', alive, '",',
     '"first_appearance": "', first_appearance, '",',
     '"appearances": ', appearances, ',',
     '"location": {',
       '"lon": ', lon, ',',
       '"lat": ', lat,
     '},',
     '"year": ', year,
  '}')
);
END
;;
DELIMITER ;
