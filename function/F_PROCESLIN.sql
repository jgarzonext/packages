--------------------------------------------------------
--  DDL for Function F_PROCESLIN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_PROCESLIN" (
   psproces IN NUMBER,
   par_tprolin IN VARCHAR2,
   pnpronum IN NUMBER,
   pnprolin IN OUT NUMBER,
   pctiplin IN NUMBER DEFAULT NULL)
   RETURN NUMBER AUTHID CURRENT_USER IS
/****************************************************************************
   NOMBRE:     pac_propio_ensa
   PROPÓSITO:  Funciones propias de ENSA

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ----------------------------------
   01.0       25/07/2011  JMF              01. 0019156 CTV - Error en carga fichero devoluciones
****************************************************************************/

   --
-- ALLIBMFM. CREA O MODIFICA UNA LINEA EN LA TABLA
-- DE CONTROL DE PROCESOS
--
   PRAGMA AUTONOMOUS_TRANSACTION;
   xprolin        NUMBER;
   -- Bug 0019156 - 25/07/2011 - JMF
   v_obj          VARCHAR2(100) := 'f_proceslin';
   v_pas          NUMBER := 100;
   v_par          VARCHAR2(2000)
      := 'p=' || psproces || ' t=' || par_tprolin || ' n=' || pnpronum || ' l=' || pnprolin
         || ' c=' || pctiplin;
   v_tprolin      procesoslin.tprolin%TYPE;
   n_error        NUMBER;
   v_usu          usuarios.cusuari%TYPE;
   v_pronum       procesoslin.npronum%TYPE;
   v_emp          procesoscab.cempres%TYPE;
   e_error        EXCEPTION;
BEGIN
   v_pas := 100;
   n_error := 0;
   -- Bug 0019156 - 25/07/2011 - JMF
   v_pronum := NVL(pnpronum, 0);
   v_usu := f_user;
   v_pas := 105;

   IF LENGTH(par_tprolin) > 120 THEN
      p_tab_error(f_sysdate, v_usu, v_obj, v_pas, 'error=104059', v_par);
      v_tprolin := SUBSTR(par_tprolin, 1, 120);
   ELSE
      v_tprolin := par_tprolin;
   END IF;

   IF pnprolin IS NOT NULL
      AND pnprolin > 0 THEN
      BEGIN
         v_pas := 110;

         UPDATE procesoslin
            SET tprolin = v_tprolin,
                npronum = v_pronum,
                fprolin = f_sysdate,
                ctiplin = DECODE(pctiplin, NULL, 1, pctiplin)
          WHERE sproces = psproces
            AND nprolin = pnprolin;

         COMMIT;
      EXCEPTION
         WHEN OTHERS THEN
            n_error := 103123;   -- ERROR AL MODIFICAR LA TAULA PROCESOSLIN
            RAISE e_error;
      END;

      n_error := 0;
   ELSE   -- PNPROLIN = NULL O IGUAL A 0
      BEGIN
         v_pas := 120;

         SELECT NVL(MAX(nprolin), 0)
           INTO xprolin
           FROM procesoslin
          WHERE sproces = psproces;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            n_error := 103120;   -- PROCÉS NO TROBAT A PROCESOSLIN
            RAISE e_error;
         WHEN OTHERS THEN
            n_error := 104058;   -- ERROR AL LLEGIR DE PROCESOSLIN
            RAISE e_error;
      END;

      BEGIN
         v_pas := 130;

         INSERT INTO procesoslin
                     (sproces, nprolin, npronum, tprolin, fprolin, cestado,
                      ctiplin)
              VALUES (psproces, xprolin + 1, v_pronum, v_tprolin, f_sysdate, 0,
                      DECODE(pctiplin, NULL, 1, pctiplin));

         COMMIT;
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            n_error := 103121;   -- LÍNIA DE PROCÉS REPETIDA A PROCESOSLIN
               p_tab_error(f_sysdate, v_usu, v_obj, v_pas, 'error1=' || n_error,
                  v_par || ' err=' || SQLCODE || ' ' || SQLERRM);
            RAISE e_error;
         WHEN OTHERS THEN
            n_error := 104059;   -- ERROR A L' INSERIR A PROCESOSLIN
               p_tab_error(f_sysdate, v_usu, v_obj, v_pas, 'error2=' || n_error,
                  v_par || ' err=' || SQLCODE || ' ' || SQLERRM);
            RAISE e_error;
      END;

      n_error := 0;
   END IF;

   v_pas := 140;
   RETURN n_error;
EXCEPTION
   -- Bug 0019156 - 25/07/2011 - JMF
   WHEN e_error THEN
      p_tab_error(f_sysdate, v_usu, v_obj, v_pas, 'error=' || n_error,
                  v_par || ' err=' || SQLCODE || ' ' || SQLERRM);
      RETURN n_error;
END;

/

  GRANT EXECUTE ON "AXIS"."F_PROCESLIN" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_PROCESLIN" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_PROCESLIN" TO "PROGRAMADORESCSI";
