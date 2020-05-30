--------------------------------------------------------
--  DDL for Function FF_GRABA_PROVISIO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."FF_GRABA_PROVISIO" (psesion IN NUMBER, pSSEGURO IN NUMBER,
  pnmovimi IN NUMBER, pfecha IN NUMBER,
  panyo IN NUMBER, pduraci IN NUMBER, porigen IN NUMBER, psproduc IN NUMBER,
  provisio IN NUMBER, pinteres IN NUMBER, pcapfall IN NUMBER, paccion IN NUMBER DEFAULT 0)
  RETURN NUMBER AUTHID current_user IS

  /*******************************************************************************************
    27/12/07. Función para llamar desde la formulación para guardar la provisión calculada
      en la tabla EVOLUPROVMATSEG
     29-3-2007. Se modifica el cálculo de la fecha que se graba en la tabla: no se le resta 1 al año
 ********************************************************************************************/

    ntraza NUMBER;
    xfecha DATE;
    xpenali NUMBER;
    xtippenali NUMBER;
    num_err NUMBER;
    v_fefecto date;
    v_anyo number;

BEGIN

  xfecha := TO_DATE(pfecha,'yyyymmdd');

  IF porigen = 0 THEN

      ntraza := 1;
--      if paccion = 3 then  -- renovación
      if paccion in (2,3) then  -- suplemento, renovación
         select falta into v_fefecto from solseguros where ssolicit = psseguro;
         v_anyo := panyo + trunc(months_between(xfecha, v_fefecto)/12);
      ELSE
         v_anyo := panyo;
      END IF;

      DELETE FROM SOLEVOLUPROVMATSEG
      WHERE ssolicit = psseguro
        AND nmovimi = pnmovimi
        AND nanyo = v_anyo;

      num_err := F_Penalizacion (3, panyo, psproduc, psseguro, xfecha, xpenali, xtippenali, 'SOL',2);

      ntraza := 2;
      INSERT INTO SOLEVOLUPROVMATSEG
        (SSOLICIT, NMOVIMI, NANYO,
        FPROVMAT, IPROVMAT, ICAPFALL, PRESCATE, PINTTEC)
      VALUES (psseguro, pnmovimi, v_anyo,
        ADD_MONTHS(xfecha, 12*(panyo)), provisio, pcapfall, 100-xpenali, pinteres);

  ELSIF porigen = 1 THEN
      ntraza := 1;
--      if paccion = 3 then --RENOVACION
      if paccion in (2,3) then  -- suplemento, renovación
         select fefecto into v_fefecto from estseguros where sseguro = psseguro;
         v_anyo := panyo + trunc(months_between(xfecha, v_fefecto)/12);
      ELSE
         v_anyo := panyo;
      END IF;

      DELETE FROM ESTEVOLUPROVMATSEG
      WHERE sseguro = psseguro
        AND nmovimi = pnmovimi
        AND nanyo = v_anyo;

      num_err := F_Penalizacion (3, panyo, psproduc, psseguro, xfecha, xpenali, xtippenali, 'EST', 2);

      ntraza := 2;
      INSERT INTO ESTEVOLUPROVMATSEG
        (SSEGURO, NMOVIMI, NANYO,
        FPROVMAT, IPROVMAT, ICAPFALL, PRESCATE, PINTTEC)
      VALUES (psseguro, pnmovimi, v_anyo,
        ADD_MONTHS(xfecha, 12*(panyo)), provisio, pcapfall, 100-xpenali, pinteres);

  ELSE

      ntraza := 1;
--      if paccion = 3 then --RENOVACIÓN
      if paccion in (2,3) then  -- suplemento, renovación
         select fefecto into v_fefecto from seguros where sseguro = psseguro;
         v_anyo := panyo + trunc(months_between(xfecha, v_fefecto)/12);
      ELSE
         v_anyo := panyo;
      END IF;
      DELETE FROM EVOLUPROVMATSEG
      WHERE sseguro = psseguro
        AND nmovimi = pnmovimi
        AND nanyo = v_anyo;

      num_err := F_Penalizacion (3, panyo, psproduc, psseguro, xfecha, xpenali, xtippenali, 'SEG', 2);

      ntraza := 2;
      INSERT INTO EVOLUPROVMATSEG
        (SSEGURO, NMOVIMI, NANYO,
        FPROVMAT, IPROVMAT, ICAPFALL, PRESCATE, PINTTEC)
      VALUES (psseguro, pnmovimi, v_anyo,
        ADD_MONTHS(xfecha, 12*(panyo)), provisio, pcapfall, 100-xpenali, pinteres);

  END IF;

  ntraza := 4;

  IF pduraci IS NULL OR pduraci = v_anyo THEN
    RETURN provisio;
  ELSE
    RETURN 0;
  END IF;

EXCEPTION
    WHEN OTHERS THEN
       p_tab_error (f_sysdate, f_user, 'ff_grava_provisio', ntraza,
         'error al insertar SSEGURO ='|| psseguro || ' pnmovimi =' || pnmovimi
         || ' PFECHA='|| pfecha ||' panyo ='|| panyo, SQLERRM);
       RETURN 0;

END; 
 
 

/

  GRANT EXECUTE ON "AXIS"."FF_GRABA_PROVISIO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."FF_GRABA_PROVISIO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."FF_GRABA_PROVISIO" TO "PROGRAMADORESCSI";
