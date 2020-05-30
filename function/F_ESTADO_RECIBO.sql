--------------------------------------------------------
--  DDL for Function F_ESTADO_RECIBO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_ESTADO_RECIBO" (
          pnrecibo IN NUMBER )
     RETURN VARCHAR2
AS
     vcestrec      NUMBER;
     vtotalrecivos NUMBER;
     vestado00       NUMBER:=0;
     vestado01       NUMBER:=0;
     vestado1       NUMBER:=0;
     vestado2       NUMBER:=0;
     CURSOR crecibos
     IS
          SELECT cestrec
          FROM movrecibo
          WHERE nrecibo = pnrecibo
          ORDER BY cestrec ASC;
     CURSOR ctotalrecibos
     IS
          SELECT COUNT(nrecibo) AS total
          FROM movrecibo
          WHERE nrecibo = pnrecibo;
BEGIN
     /*Total de registros encontrados*/
     OPEN ctotalrecibos;
     LOOP
          FETCH ctotalrecibos
          INTO vtotalrecivos;
          EXIT
     WHEN ctotalrecibos%NOTFOUND;
     END LOOP;
     CLOSE ctotalrecibos;
     /*PENDIENTE si en la tabla MOVRECIBO , Solo hay un registro de ese recibo con CESTREC=0*/
     IF vtotalrecivos =1 THEN
          vestado00:=0;
          OPEN crecibos;
          LOOP
               FETCH crecibos
               INTO vcestrec;
               EXIT
          WHEN crecibos%NOTFOUND;
               IF vcestrec =0 THEN
                    vestado00:=vestado00+1;
               END IF;
          END LOOP;
          CLOSE crecibos;
          IF vestado00=1 THEN
               RETURN 'PENDIENTE';
          END IF;
     END IF;
     /*COBRADO si en la tabla MOVRECIBO , Solo hay dos registros de ese recibo con CESTREC=0 y CESTREC=1*/
     IF vtotalrecivos =2 THEN
          vestado00:=0;
          vestado1:=0;
          OPEN crecibos;
          LOOP
               FETCH crecibos
               INTO vcestrec;
               EXIT
          WHEN crecibos%NOTFOUND;
               IF vcestrec =0 THEN
                    vestado00:=vestado00+1;
               END IF;
               IF vcestrec =1 THEN
                    vestado1:=vestado1+1;
               END IF;
          END LOOP;
          CLOSE crecibos;
          IF vestado00=1 AND vestado1=1 THEN
               RETURN 'COBRADO';
          END IF;
     END IF;
     /*IMPAGADO si en la tabla MOVRECIBO , Solo hay tres registros de ese recibo con CESTREC=0 , CESTREC=1 y CESTREC=0*/
     IF vtotalrecivos =3 THEN
          vestado00:=1;
          vestado01:=2;
          vestado1:=0;
          OPEN crecibos;
          LOOP
               FETCH crecibos
               INTO vcestrec;
               EXIT
          WHEN crecibos%NOTFOUND;
               IF vcestrec =0 AND vestado00=1 THEN
                    vestado00:=vestado00+1;
               END IF;
               IF vcestrec =1 THEN
                    vestado1:=vestado1+1;
               END IF;
               IF vcestrec =0 AND vestado01=2 THEN
                    vestado01:=vestado01+1;
               END IF;
          END LOOP;
          CLOSE crecibos;
          IF vestado00=1 AND vestado1=1 AND vestado01=1 THEN
               RETURN 'IMPAGADO';
          END IF;
     END IF;
     /*ANULADO si en la tabla MOVRECIBO , Solo hay 4 registros de ese recibo con CESTREC=0 , CESTREC=1 , CESTREC=0 y CESTREC=2*/
     IF vtotalrecivos =4 THEN
          vestado00:=1;
          vestado01:=2;
          vestado1:=0;
          vestado2:=0;
          OPEN crecibos;
          LOOP
               FETCH crecibos
               INTO vcestrec;
               EXIT
          WHEN crecibos%NOTFOUND;
               IF vcestrec =0 AND vestado00=1 THEN
                    vestado00:=vestado00+1;
               END IF;
               IF vcestrec =1 THEN
                    vestado1:=vestado1+1;
               END IF;
               IF vcestrec =0 AND vestado00=2 THEN
                    vestado01:=vestado01+1;
               END IF;
               IF vcestrec =2 THEN
                    vestado1:=vestado1+1;
               END IF;
          END LOOP;
          CLOSE crecibos;
          IF vestado00=1 AND vestado1=1 AND vestado01=1 AND vestado2=1 THEN
               RETURN 'ANULADO';
          END IF;
     END IF;
     /*ANULADO COBRADO si en la tabla MOVRECIBO , Solo hay dos registros de ese recibo con CESTREC=1 y CESTREC=2*/
     IF vtotalrecivos =2 THEN
          vestado1:=0;
          vestado2:=0;
          OPEN crecibos;
          LOOP
               FETCH crecibos
               INTO vcestrec;
               EXIT
          WHEN crecibos%NOTFOUND;
               IF vcestrec =1 THEN
                    vestado1:=vestado1+1;
               END IF;
               IF vcestrec =2 THEN
                    vestado2:=vestado2+1;
               END IF;
          END LOOP;
          CLOSE crecibos;
          IF vestado1=1 AND vestado2=1 THEN
               RETURN 'ANULADO COBRADO';
          END IF;
     END IF;
     RETURN '';
END F_ESTADO_RECIBO;

/

  GRANT EXECUTE ON "AXIS"."F_ESTADO_RECIBO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_ESTADO_RECIBO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_ESTADO_RECIBO" TO "PROGRAMADORESCSI";
