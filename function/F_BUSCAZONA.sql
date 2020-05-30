--------------------------------------------------------
--  DDL for Function F_BUSCAZONA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_BUSCAZONA" (
    pcempres IN NUMBER, pcagente IN NUMBER,
    pctipage IN NUMBER, pfbusca  IN DATE) RETURN NUMBER authid current_user IS
/*****************************************************************
    F_BUSCAZONA:
    Aquesta funció té el propòsit:
    a)     Es retorna el codi del pare del agent que es
        correspongui amb l'empresa, amb el tipus
        i el periode sol.licitat ( pctipage informat).
     b) En cas d'error torna un número negatiu
        -1 : Paràmetre obligatori és a NULL
        -2 : Depende de más de un agente
        -3 : No se ha encontrado el agente del que depende
        -4 : Error en la tabla REDCOMERCIAL
        -5 : La tabla REDCOMERCIAL no tiene estructura de arbol
*****************************************************************/
    xfbusca  DATE;
    cagente  REDCOMERCIAL.CAGENTE%TYPE;
    ex_bad_structure  EXCEPTION;
    PRAGMA EXCEPTION_INIT(ex_bad_structure, -1436);
BEGIN
    IF pcempres IS NULL OR  pcagente IS NULL OR  pctipage IS NULL  THEN
          cagente := -1;
    ELSE
      xfbusca := NVL(pfbusca,F_SYSDATE);

      BEGIN
        SELECT cagente
        INTO cagente
        FROM
        (
            SELECT r.cagente, r.ctipage
                FROM redcomercial r
                WHERE   r.fmovini <= xfbusca
                            AND (r.fmovfin > xfbusca OR r.fmovfin IS NULL)
                    AND r.cempres = pcempres
                START WITH r.cagente = pcagente
                CONNECT BY r.cagente = PRIOR cpadre and PRIOR fmovfin IS NULL
        )
        WHERE ctipage = pctipage
        ;

    EXCEPTION
        WHEN TOO_MANY_ROWS THEN
            cagente:= -2 ; --Depende de más de un agente
        WHEN NO_DATA_FOUND THEN
            cagente:= -3; --No se ha encontrado el agente del que depende
        WHEN ex_bad_structure THEN
            cagente := -5; -- La tabla REDCOMERCIAL no tiene estructura de arbol
        WHEN OTHERS THEN
            cagente:= -4; --Error en la tabla REDCOMERCIAL
    END;
  END IF;
  RETURN(cagente);
END;
 

/

  GRANT EXECUTE ON "AXIS"."F_BUSCAZONA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_BUSCAZONA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_BUSCAZONA" TO "PROGRAMADORESCSI";
