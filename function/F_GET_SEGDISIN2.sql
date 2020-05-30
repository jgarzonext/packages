--------------------------------------------------------
--  DDL for Function F_GET_SEGDISIN2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_GET_SEGDISIN2" (psseguro IN NUMBER, pcesta IN NUMBER, pmodalitat IN NUMBER DEFAULT NULL) RETURN NUMBER IS
  /*
    RSC 16/01/2008
    Retorna la distribución de una cesta dentro del modelo de inversión vigente
  */
  vresultat  NUMBER;
  vnmovimi   NUMBER;
BEGIN
    select max(nmovimi) INTO vnmovimi
    from segdisin2
    where sseguro = psseguro
      and ffin is null;

    IF pmodalitat IS NOT NULL THEN
      select pdistrec INTO vresultat
      from segdisin2
      where sseguro = psseguro
        and ccesta = pcesta
        and nmovimi = (select max(nmovimi)
                       from segdisin2
                       where sseguro = psseguro
                         and ccesta = pcesta
                         and ffin is null
                         and nmovimi < vnmovimi)
        and ffin is null;
    ELSE
      select pdistrec INTO vresultat
      from segdisin2
      where sseguro = psseguro
        and ccesta = pcesta
        and nmovimi = vnmovimi
        and ffin is null;
    END IF;

    RETURN vresultat;
EXCEPTION
  WHEN OTHERS THEN
    RETURN 180726;
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_GET_SEGDISIN2" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_GET_SEGDISIN2" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_GET_SEGDISIN2" TO "PROGRAMADORESCSI";
