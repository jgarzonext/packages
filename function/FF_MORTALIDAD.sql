--------------------------------------------------------
--  DDL for Function FF_MORTALIDAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."FF_MORTALIDAD" 
          (sesion      in number,
           ptabla      IN number,
           pedad       in number,
           psexo       in number,
           pnano_nacim in  number,
           ptipo       in number,
           psimbolo       in varchar2)
           RETURN NUMBER AUTHID current_user IS

  resultado  NUMBER := 0;
  vL1        NUMBER;
  vL2        NUMBER;
-- MSR 14/6/2007  Evitar que falli amb un DIVIDE_BY_ZERO quan v_lx valgui 0 i demanin psimbolo='LX' o 'DX'
BEGIN

    /* dramon 4-9-2008: Esta select está haciendo un producto cartesiano, se cambia a la manera más simple *
    SELECT CASE UPPER(psimbolo)
             WHEN 'LX' THEN l1
             WHEN 'DX' THEN l1 - l2
             WHEN 'PX' THEN l2 / l1
             WHEN 'QX' THEN(l1-l2)/l1
             ELSE NULL
          END
      INTO resultado
    FROM
    (
    SELECT CASE psexo WHEN 1 THEN a.vmascul WHEN 2 THEN a.vfemeni ELSE NULL END l1,
           CASE psexo WHEN 1 THEN b.vmascul WHEN 2 THEN b.vfemeni ELSE NULL END l2
      FROM mortalidad a, mortalidad b
      WHERE     (a.nano_nacim = pnano_nacim OR pnano_nacim IS NULL)
            AND a.ctabla = ptabla
            AND a.nedad = pedad
        AND (a.ctipo = ptipo or ptipo is null)
            AND (b.nano_nacim = pnano_nacim OR pnano_nacim IS NULL)
            AND b.ctabla = ptabla
            AND b.nedad = pedad+1
        AND (b.ctipo = ptipo or ptipo is null)
    )
    ;*/

  -- L1
  IF psimbolo IS NOT NULL THEN
    SELECT decode (psexo, 1, a.vmascul, 2, a.vfemeni, NULL)
      INTO vL1
      FROM mortalidad a
      WHERE     (a.nano_nacim = pnano_nacim OR pnano_nacim IS NULL)
            AND a.ctabla = ptabla
            AND a.nedad = pedad
        AND (a.ctipo = ptipo or ptipo is null);
  END IF;

  -- L2
  IF upper (psimbolo) IN ('DX', 'PX', 'QX') THEN
    SELECT decode (psexo, 1, b.vmascul, 2, b.vfemeni, NULL)
      INTO vL2
      FROM mortalidad b
      WHERE     (b.nano_nacim = pnano_nacim OR pnano_nacim IS NULL)
            AND b.ctabla = ptabla
            AND b.nedad = pedad+1
        AND (b.ctipo = ptipo or ptipo is null);
  END IF;

  IF upper (psimbolo) = 'LX' THEN
    resultado := vL1;
  ELSIF upper (psimbolo) = 'DX' THEN
    resultado := vL1 - vL2;
  ELSIF upper (psimbolo) = 'PX' THEN
    resultado := vL2 / vL1;
  ELSIF upper (psimbolo) = 'QX' THEN
    resultado := (vL1 - vL2) / vL1;
  ELSE
    resultado := NULL;
  END IF;

  RETURN resultado;
EXCEPTION
  WHEN No_Data_Found THEN
    RETURN 0;   -- Si no ha trobat dades (p.ex. és major que 127) torna 0
  WHEN OTHERS THEN
    RETURN 111419;
END ff_mortalidad;
 
 

/

  GRANT EXECUTE ON "AXIS"."FF_MORTALIDAD" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."FF_MORTALIDAD" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."FF_MORTALIDAD" TO "PROGRAMADORESCSI";
