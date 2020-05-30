--------------------------------------------------------
--  DDL for Package Body PAC_FIC_PROCESOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_FIC_PROCESOS" IS
        /******************************************************************************
          NOMBRE:       PAC_FIC_PROCESOS
     PROPÓSITO: Nuevo paquete de la capa Negocio que tendrá las funciones para la gestión de procesos del gestor de informes.
                Controlar todos posibles errores con PAC_IOBJ_MNSAJES.P_TRATARMENSAJE


     REVISIONES:
     Ver        Fecha        Autor             Descripción
     ---------  ----------  ---------------  ------------------------------------
     1.0        16/06/2009   JMG                1. Creación del package.
   ******************************************************************************/

   /*   F_get_Ficprocesos
   Nueva función de la capa lógica que devolverá los procesos generados por herramienta gestor.

   Parámetros

   1. pcempres IN NUMBER
   2. psproces IN NUMBER
   3. ptgestor IN VARCHAR2
   4. ptformat IN VARCHAR2
   5. ptanio   IN VARCHAR2
   6. ptmes    IN VARCHAR2
   7. ptdiasem IN VARCHAR2
   8. pcusuari IN VARCHAR2
   9. pfproini IN DATE
   10. pidioma IN NUMBER
   11. psquery OUT VARCHAR2*/
   FUNCTION f_get_ficprocesos(
      pcempres IN NUMBER,
      psproces IN NUMBER,
      ptgestor IN VARCHAR2,
      ptformat IN VARCHAR2,
      ptanio IN VARCHAR2,
      ptmes IN VARCHAR2,
      ptdiasem IN VARCHAR2,
      pnerror IN NUMBER,
      pcusuari IN VARCHAR2,
      pfproini IN DATE,
      pcidioma IN NUMBER,   -- Idioma
      psquery OUT VARCHAR2)
      RETURN NUMBER IS
      vformat        VARCHAR2(200) := NULL;
   BEGIN
      IF ptformat IS NOT NULL THEN
         vformat := ' and p.tformat =' || TO_CHAR(ptformat) || ' ';
      END IF;

      psquery :=
         'SELECT p.sproces,g.tnombre gestor,f.tnombre formato,p.tanio,p.tmes,p.tdiasem,p.cusuari,p.fproini,p.cproces,p.nerror,p.tproces,p.fprofin '
         || 'FROM fic_procesos p INNER JOIN fic_gestores g ON g.tgestor = p.tgestor LEFT JOIN fic_formatos f ON f.tformat = p.tformat AND f.tgestor = p.tgestor '
         || 'WHERE p.cempres = ' || TO_CHAR(pcempres) || ' and ' || ' p.sproces = NVL ('
         || NVL(TO_CHAR(psproces), 'NULL') || ',p.sproces) ' || ' and ' || ' p.tgestor = NVL ('
         || NVL(TO_CHAR(ptgestor), 'NULL') || ',p.tgestor) ' || NVL(vformat, ' ') || ' and '
         || ' p.tanio = NVL (' || NVL(TO_CHAR(ptanio), 'NULL') || ',p.tanio) ' || ' and '
         || ' p.tmes = NVL (' || NVL(TO_CHAR(ptmes), 'NULL') || ',p.tmes) ' || ' and '
         || ' p.tdiasem = NVL (' || NVL(TO_CHAR(ptdiasem), 'NULL') || ',p.tdiasem) ' || ' and '
         || ' p.cusuari = NVL (' || NVL(TO_CHAR(pcusuari), 'NULL') || ',p.cusuari) '
         || ' and  p.nerror = NVL (' || NVL(TO_CHAR(pnerror), 'NULL') || ',p.nerror) '
         || ' and ' || ' p.fproini = NVL (' || NVL(TO_CHAR(pfproini), 'NULL') || ',p.fproini) ';
      --p_control_error('fic_procesos', 'query', psquery);
      RETURN 0;
   END f_get_ficprocesos;

         /*
    Nueva función de la capa lógica que devolverá numero de procesos activos.


    Parámetros

    1. pcempres IN NUMBER
    2. psproces IN NUMBER
    3. ptgestor IN VARCHAR2
    4. ptformat IN VARCHAR2
    5. ptanio   IN VARCHAR2
    6. ptmes    IN VARCHAR2
    7. ptdiasem IN VARCHAR2
    8. pnumpro  OUT NUMBER
   */
   FUNCTION f_get_numficprocesos(
      pcempres IN NUMBER,
      ptgestor IN VARCHAR2,
      ptformat IN VARCHAR2,
      ptanio IN VARCHAR2,
      ptmes IN VARCHAR2,
      ptdiasem IN VARCHAR2,
      pnumpro OUT NUMBER)
      RETURN NUMBER IS
   BEGIN
      SELECT COUNT(sproces)
        INTO pnumpro
        FROM fic_procesos
       WHERE cempres = pcempres
         AND tgestor = ptgestor
         AND tformat = NVL(ptformat, tformat)
         AND tanio = NVL(ptanio, tanio)
         AND tmes = NVL(ptmes, tmes)
         AND tdiasem = NVL(ptdiasem, tdiasem)
         AND fprofin IS NULL;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_fic_procesos.f_get_numficprocesos', 1000005,
                     'Error', SQLERRM);
         RETURN 1000005;
   END f_get_numficprocesos;

   /*   f_get_ficprocesosdet
     Nueva función de la capa lógica que devolverá los detalles de proceso.

     Parámetros

     1. psproces IN NUMBER
     2. mensajes  OUT psquery*/
   FUNCTION f_get_ficprocesosdet(psproces IN NUMBER, psquery OUT VARCHAR2)
      RETURN NUMBER IS
   BEGIN
      psquery :=
         'SELECT p.SPROCES,p.NPROLIN,P.TPATHFI, p.FPROLIN,p.CTIPLIN, d.tatribu, to_char(p.fprolin,''dd/mm/yyyy'') tfprolin
                 FROM fic_procesos_detalle p, detvalores d WHERE SPROCES = '
         || psproces || ' and d.cvalor = 713 and d.cidioma = '
         || pac_md_common.f_get_cxtidioma || ' and d.catribu = p.ctiplin';
      RETURN 0;
   END f_get_ficprocesosdet;

     /*  f_alta_proceso
    Nueva función de la capa lógica que dará de alta el proceso registrado.

    Parámetros

    1. pcusuari IN VARCHAR2
    2. pcempres IN NUMBER
    3. pcproces IN VARCHAR2
    4. ptproces IN VARCHAR2
    5. psproces OUT NUMBER
   */
   FUNCTION f_alta_procesoini(
      pcusuari IN VARCHAR2,   /* Usuario de la ejecución */
      pcempres IN NUMBER,   /* Empresa asociada */
      ptgestor IN VARCHAR2,   /* Gestor asociado */
      ptformat IN VARCHAR2,   /* Formato asociado */
      ptanio IN VARCHAR2,   /* año asociado */
      ptmes IN VARCHAR2,   /* mes asociado */
      ptdiasem IN VARCHAR2,   /* dia semana asociado */
      pcproces IN VARCHAR2,   /* Código de proceso */
      ptproces IN VARCHAR2,   /* Texto del proceso */
      psproces IN OUT NUMBER)   /* Número de proceso */
      RETURN NUMBER IS
      PRAGMA AUTONOMOUS_TRANSACTION;
      wfecha         DATE;
   BEGIN
-- Recuperamos la fecha
      SELECT F_SYSDATE
        INTO wfecha
        FROM DUAL;

-- Recuperamos el sigueinte código de proceso
      SELECT sproces.NEXTVAL
        INTO psproces
        FROM DUAL;

-- Damos de alta el proceso
      INSERT INTO fic_procesos
                  (sproces, cempres, tgestor, tformat, tanio, tmes, tdiasem, cusuari,
                   fproini, cproces, nerror, tproces, fprofin)
           VALUES (psproces, pcempres, ptgestor, ptformat, ptanio, ptmes, ptdiasem, pcusuari,
                   wfecha, pcproces, 0, ptproces, NULL);

      COMMIT;
      RETURN 0;
   END f_alta_procesoini;

   /*  f_alta_proceso_detalle
     Nueva función de la capa lógica que dará de alta el detalle del proceso registrado.

     Parámetros

     1. psproces IN VARCHAR2
     2. par_tprolin IN NUMBER
     3. pnpronum IN VARCHAR2
     4. pnprolin IN VARCHAR2
     5. pctiplin OUT NUMBER
    */
   FUNCTION f_alta_proceso_detalle(
      psproces IN NUMBER,
      par_tprolin IN VARCHAR2,
      ptpathfi IN VARCHAR2,
      pnprolin IN OUT NUMBER,
      pctiplin IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      PRAGMA AUTONOMOUS_TRANSACTION;
      xprolin        NUMBER;
      v_obj          VARCHAR2(100) := 'f_alta_proceso_detalle';
      v_pas          NUMBER := 100;
      v_par          VARCHAR2(2000)
         := 'p=' || psproces || ' t=' || par_tprolin || ' l=' || pnprolin || ' c=' || pctiplin;
      n_error        NUMBER;
      v_usu          usuarios.cusuari%TYPE;
      e_error        EXCEPTION;
   BEGIN
      v_pas := 100;
      n_error := 0;
      v_usu := f_user;
      v_pas := 105;

      IF LENGTH(par_tprolin) > 120 THEN
         p_tab_error(f_sysdate, v_usu, v_obj, v_pas, 'error=104059', v_par);
      END IF;

      IF pnprolin IS NOT NULL
         AND pnprolin > 0 THEN
         BEGIN
            v_pas := 110;

            UPDATE fic_procesos_detalle
               SET tpathfi = ptpathfi,
                   fprolin = f_sysdate,
                   ctiplin = DECODE(pctiplin, NULL, 1, pctiplin)
             WHERE sproces = psproces
               AND nprolin = pnprolin;

            COMMIT;
         EXCEPTION
            WHEN OTHERS THEN
               n_error := 103123;   -- ERROR AL MODIFICAR LA TAULA FIC_PROCESOS_DETALLE
               RAISE e_error;
         END;

         n_error := 0;
      ELSE   -- FIC_PROCESOS_DETALLE = NULL O IGUAL A 0
         BEGIN
            v_pas := 120;

            SELECT NVL(MAX(nprolin), 0)
              INTO xprolin
              FROM fic_procesos_detalle
             WHERE sproces = psproces;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               n_error := 103120;   -- PROCÉS NO TROBAT A FIC_PROCESOS_DETALLE
               RAISE e_error;
            WHEN OTHERS THEN
               n_error := 104058;   -- ERROR AL LLEGIR DE FIC_PROCESOS_DETALLE
               RAISE e_error;
         END;

         BEGIN
            v_pas := 130;

            INSERT INTO fic_procesos_detalle
                        (sproces, nprolin, tpathfi, fprolin,
                         ctiplin)
                 VALUES (psproces, xprolin + 1, ptpathfi, f_sysdate,
                         DECODE(pctiplin, NULL, 1, pctiplin));

            COMMIT;
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               n_error := 103121;   -- LÍNIA DE PROCÉS REPETIDA A FIC_PROCESOS_DETALLE
               RAISE e_error;
            WHEN OTHERS THEN
               n_error := 104059;   -- ERROR A L' INSERIR A FIC_PROCESOS_DETALLE
               RAISE e_error;
         END;

         n_error := 0;
      END IF;

      v_pas := 140;
      RETURN n_error;
   EXCEPTION
      WHEN e_error THEN
         p_tab_error(f_sysdate, v_usu, v_obj, v_pas, 'error=' || n_error,
                     v_par || ' err=' || SQLCODE || ' ' || SQLERRM);
         RETURN n_error;
   END f_alta_proceso_detalle;

   /*  f_update_procesofin
     Nueva función de la capa lógica que dará de alta el detalle del proceso registrado.

     Parámetros

     1. psproces IN VARCHAR2
     2. pnerror IN NUMBER
      */
   FUNCTION f_update_procesofin(psproces IN NUMBER, pnerror IN NUMBER)
      RETURN NUMBER IS
--
-- Descripción: Finaliza un proceso.
-- Parámetros :
--               psproces: nº de proceso a finalizar
--               pnerror : nº de errores en el proceso
--
      PRAGMA AUTONOMOUS_TRANSACTION;
      wfecha         DATE;
      wproces        NUMBER;
   BEGIN
-- Recuperamos la fecha
      SELECT F_SYSDATE
        INTO wfecha
        FROM DUAL;

-- Validamos la existencia del proceso
      BEGIN
         SELECT sproces
           INTO wproces
           FROM fic_procesos
          WHERE sproces = psproces;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN 1;
         WHEN TOO_MANY_ROWS THEN
            RETURN 2;
      END;

-- Actualizamos la información del proceso
      UPDATE fic_procesos
         SET fprofin = wfecha,
             nerror = pnerror
       WHERE sproces = psproces;

      COMMIT;
      RETURN 0;
   END f_update_procesofin;
END pac_fic_procesos;

/

  GRANT EXECUTE ON "AXIS"."PAC_FIC_PROCESOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_FIC_PROCESOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_FIC_PROCESOS" TO "PROGRAMADORESCSI";
