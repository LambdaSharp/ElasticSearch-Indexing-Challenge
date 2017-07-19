DROP TRIGGER IF EXISTS TR_heroes;

DELIMITER ;;

CREATE TRIGGER TR_heroes
AFTER INSERT ON heroes
FOR EACH ROW
  BEGIN
    SELECT NEW.id, NEW.name, NEW.urlslug, NEW.identity, NEW.alignment, NEW.eye_color, NEW.hair_color, NEW.sex, NEW.gsm, NEW.alive, NEW.appearances, NEW.first_appearance, NEW.year, NEW.lon, NEW.lat
      INTO @id, @name, @urlslug, @identity, @alignment, @eye_color, @hair_color, @sex, @gsm, @alive, @appearances, @first_appearance, @year, @lon, @lat;
    CALL LAMBDASHARP_proc("INSERT", @id, @name, @urlslug, @identity, @alignment, @eye_color, @hair_color, @sex, @gsm, @alive, @appearances, @first_appearance, @year, @lon, @lat);
  END
;;
DELIMITER ;


DROP TRIGGER IF EXISTS TR_heroes_update;

DELIMITER ;;

CREATE TRIGGER TR_heroes_update
AFTER UPDATE ON heroes
FOR EACH ROW
  BEGIN
  SELECT NEW.id, NEW.name, NEW.urlslug, NEW.identity, NEW.alignment, NEW.eye_color, NEW.hair_color, NEW.sex, NEW.gsm, NEW.alive, NEW.appearances, NEW.first_appearance, NEW.year, NEW.lon, NEW.lat
  INTO @id, @name, @urlslug, @identity, @alignment, @eye_color, @hair_color, @sex, @gsm, @alive, @appearances, @first_appearance, @year, @lon, @lat;
  CALL LAMBDASHARP_proc("UPDATE", @id, @name, @urlslug, @identity, @alignment, @eye_color, @hair_color, @sex, @gsm, @alive, @appearances, @first_appearance, @year, @lon, @lat);
  END
;;
DELIMITER ;

DROP TRIGGER IF EXISTS TR_heroes_delete;

DELIMITER ;;

CREATE TRIGGER TR_heroes_delete
AFTER DELETE ON heroes
FOR EACH ROW
BEGIN
SELECT OLD.id, OLD.name, OLD.urlslug, OLD.identity, OLD.alignment, OLD.eye_color, OLD.hair_color, OLD.sex, OLD.gsm, OLD.alive, OLD.appearances, OLD.first_appearance, OLD.year, OLD.lon, OLD.lat
INTO @id, @name, @urlslug, @identity, @alignment, @eye_color, @hair_color, @sex, @gsm, @alive, @appearances, @first_appearance, @year, @lon, @lat;
CALL LAMBDASHARP_proc("DELETE", @id, @name, @urlslug, @identity, @alignment, @eye_color, @hair_color, @sex, @gsm, @alive, @appearances, @first_appearance, @year, @lon, @lat);
END
;;
DELIMITER ;

