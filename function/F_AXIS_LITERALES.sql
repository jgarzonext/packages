--------------------------------------------------------
--  DDL for Function F_AXIS_LITERALES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_AXIS_LITERALES" (pnumlit IN NUMBER, pidioma IN NUMBER DEFAULT -1) RETURN VARCHAR2 IS

    PRAGMA autonomous_transaction;

    CURSOR c1 IS
        SELECT l.*
          FROM literales l
         WHERE l.slitera = pnumlit;

    vttexto     axis_literales.tlitera%type;
    vnum        NUMBER (8):=0;
    vtiplitera  NUMBER (8):=0;
    vidioma     NUMBER (8);

BEGIN

    IF pidioma = -1 THEN
        vidioma := pac_md_common.f_get_cxtidioma;
    ELSE
        vidioma := pidioma;
    END IF;

    BEGIN

        begin

            SELECT l.tlitera
            INTO vttexto
            FROM AXIS_LITERALES_INSTALACION l
            WHERE l.CIDIOMA = vidioma
            AND l.SLITERA = pnumlit;

        exception
            when no_data_found then

            SELECT l.tlitera
            INTO vttexto
            FROM AXIS_LITERALES l
            WHERE l.CIDIOMA = vidioma
            AND l.SLITERA = pnumlit;
        end;
        RETURN vttexto;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            BEGIN
                SELECT l.tlitera
                  INTO vttexto
                  FROM literales l
                 WHERE l.cidioma = vidioma
                   AND l.slitera = pnumlit;

                FOR c IN c1 LOOP

                    --segurament tampoc hi seran a axis_codliterales...però ho comprovem
                    SELECT COUNT(*)
                      INTO vnum
                      FROM AXIS_CODLITERALES
                     WHERE slitera = pnumlit;

                    IF vnum = 0 THEN
                       SELECT c.clitera
                         INTO vtiplitera
                         FROM codliterales c
                        WHERE c.slitera = pnumlit;

                       INSERT INTO AXIS_CODLITERALES (slitera,clitera) VALUES (c.slitera, vtiplitera);
                    END IF;

                    --on no era segur és a axis_literales
                    INSERT INTO AXIS_LITERALES (cidioma,slitera,tlitera) VALUES (c.cidioma,c.slitera,c.tlitera);

                    COMMIT;
                END LOOP;

                RETURN vttexto;
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                RETURN NULL;
            END;
    END;
END F_AXIS_LITERALES;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_AXIS_LITERALES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_AXIS_LITERALES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_AXIS_LITERALES" TO "PROGRAMADORESCSI";
