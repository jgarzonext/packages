--------------------------------------------------------
--  DDL for Package Body PAC_SUPLEM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_SUPLEM" 
AS
   FUNCTION f_suplem_car(
      psproces     IN       NUMBER,
      indice_err   IN OUT   NUMBER,
      pfdesde      IN       DATE,
      pfhasta      IN       DATE,
      pmodo                 NUMBER)
      RETURN NUMBER
   IS
      /*   función  que ejecuta los diferentes suplementos, retorna el numero
       de error. ;
       Indice_err : el numero de polizas con errores */
      CURSOR c_funcions
      IS
         SELECT   tprocedim
             FROM codsuplemencar
         ORDER BY norden;
      pol_err    NUMBER        := 0; --polizas erroneas.
      num_err    NUMBER        := 0;
      v_proc     VARCHAR2(150); --procedim a ejecutar
   BEGIN
      IF psproces IS NOT NULL THEN
         -- insertar los paramentros en tabla temporal.
         num_err     := f_insparametros(
                           psproces, 'DESDE', TO_NUMBER(
                                                 TO_CHAR(pfdesde, 'yyyymmdd')));
         num_err     := f_insparametros(
                           psproces, 'HASTA', TO_NUMBER(
                                                 TO_CHAR(pfhasta, 'yyyymmdd')));
         num_err     := f_insparametros(psproces, 'MODO', TO_NUMBER(pmodo)); -- R = 0,P = 1
         IF num_err <> 0 THEN
            RETURN num_err; --error al insertar los parametros de suplemento
         END IF;
         FOR c IN c_funcions
         LOOP
            BEGIN
               -- llamada a los procedimientos de suplementos (dinamicamente).
               v_proc      := 'pac_suplem.num_err := ' || c.tprocedim || '(' ||
                              psproces || ')';
               dyn_plsql(v_proc,num_err);
               --prueba(v_proc);
               -- actualizacion de polizas erroneas
               DBMS_OUTPUT.put_line(pac_suplem.num_err);
               pol_err     := pol_err + pac_suplem.num_err;
               pac_suplem.num_err := 0;
               v_proc      := NULL;
            END;
         END LOOP;
         RETURN 0;
      ELSE
         RETURN 103224;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         DBMS_OUTPUT.put_line(SQLERRM);
         RETURN 111662;
   END f_suplem_car;
   FUNCTION f_insparametros(
      psproces   NUMBER,
      pclave     VARCHAR2,
      pvalor     NUMBER)
      RETURN NUMBER
   IS
--inserta los parametros necesarios para todos los suplementos
--en caso de error retorna en num_err, aqui es donde se tendrán
--que ir añadiendo todos los parametros que se necesiten para
--cualquier suplemento
      num_err    NUMBER := 0;
   BEGIN
      BEGIN
         DELETE parms_suplementos
          WHERE sesion = psproces
            AND parametro = pclave;
         INSERT INTO parms_suplementos
              VALUES (psproces, pclave, pvalor);
      END;
      RETURN num_err;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 111663;
   END f_insparametros;
   FUNCTION f_seguroscar(
      psproces   NUMBER,
      psseguro   NUMBER,
      pnriesgo   NUMBER,
      pcmotmov   NUMBER,
      pnerror    NUMBER DEFAULT NULL)
      RETURN NUMBER
   IS
      num_lin    NUMBER;
   BEGIN
      IF NVL(pnerror, 0) = 0 THEN
         --sin errores guardar en seguroscar estado 0
         BEGIN
            INSERT INTO seguroscar
                        (ssesion, sseguro, nriesgo, cmotmov, nerror, cestado)
                 VALUES (psproces, psseguro, pnriesgo, pcmotmov, NULL, 0);
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               UPDATE seguroscar
                  SET nerror = NULL,
                      cestado = 0
                WHERE ssesion = psproces
                  AND sseguro = psseguro
                  AND cmotmov = pcmotmov
                  AND nriesgo = pnriesgo;
            WHEN OTHERS THEN
               DBMS_OUTPUT.put_line(SQLERRM);
               RETURN 111664;
         END;
      ELSE
         BEGIN
            INSERT INTO seguroscar
                        (ssesion, sseguro, nriesgo, cmotmov, nerror, cestado)
                 VALUES (psproces, psseguro, pnriesgo, pcmotmov, pnerror, 1);
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               UPDATE seguroscar
                  SET nerror = pnerror,
                      cestado = 1
                WHERE ssesion = psproces
                  AND sseguro = psseguro
                  AND cmotmov = pcmotmov;
            WHEN OTHERS THEN
               DBMS_OUTPUT.put_line('mensxxxxxxxxxxx'|| SQLERRM);
               num_err     := f_proceslin(
                                 psproces, 'error al insertar en seguroscar',
                                 psseguro, num_lin);
               RETURN 111664;
         END;
      END IF;
      RETURN 0;
   END f_seguroscar;
END pac_suplem;

/

  GRANT EXECUTE ON "AXIS"."PAC_SUPLEM" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_SUPLEM" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_SUPLEM" TO "PROGRAMADORESCSI";
