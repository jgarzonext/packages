--------------------------------------------------------
--  DDL for Package Body PAC_CBANCAR_SEG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_CBANCAR_SEG" AS
/******************************************************************************
   NOMBRE:    PAC_CBANCAR_SEG
   PROPÓSITO: Retornará las Cuentas bancarias

   REVISIONES:
   Ver        Fecha       Autor            Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        16/01/2009  MCC              1. Creación del package.
   2.0        23/03/2010  XPL              2. APR - 0013779: domiciliation - no record
******************************************************************************/

   /*************************************************************************
      Retorna un cursor con el histórico de cuentas asociadas a una póliza
      param in PSSEGURO : código seguro
      param out PRESULT  : cursor de resultados
      param out MENSAJES : mensajes de error
   *************************************************************************/
   FUNCTION f_get_cbancar_seghis(psseguro IN NUMBER, presult OUT sys_refcursor)
      RETURN NUMBER IS
      v_query        VARCHAR2(1000);
      vobject        VARCHAR2(200) := 'PAC_CBANCAR_SEG.F_GET_CBANCAR_SEGHIS';
      mensajes       t_iax_mensajes;
      e_param_error  EXCEPTION;
      e_object_error EXCEPTION;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(900) := 'F_GET_CBANCAR_SEGHIS PARAMETROS: SSEGURO=' || psseguro;
      cbancc         ob_iax_ccc := ob_iax_ccc();
      cbanccs        t_iax_ccc := t_iax_ccc();
      nerr           NUMBER;
      RESULT         VARCHAR2(100);
   BEGIN
      v_query :=
         'SELECT SEGB.FINIEFE, SEGB.FFINEFE, PAC_CBANCAR_SEG.FF_FormatCCC(4,SEGB.CBANCAR) tcbancar , PAC_CBANCAR_SEG.FF_FormatCCC(4,SEGB.CBANCOB) tcbancob  FROM SEG_CBANCAR SEGB'
         || ' WHERE SEGB.SSEGURO = ' || psseguro;
      presult := pac_iax_listvalores.f_opencursor(v_query, mensajes);
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         IF presult%ISOPEN THEN
            CLOSE presult;
         END IF;

         p_tab_error(f_sysdate, f_user, 'PAC_CBANCAR_SEG', 1,
                     'PAC_CBANCAR_SEG.F_GET_CBANCAR_SEGHIS' || 9000776, SQLERRM);
         RETURN 9000776;
   END f_get_cbancar_seghis;

   /*************************************************************************
        Retorna la última cuenta de cargo asociada a la póliza
        param in PSSEGURO  : código seguro
        param in DATE      : fecha
        param out PCBANCAR : cuenta bancaria
        param out PCBANCOB : cuenta de cobro
     *************************************************************************/
   FUNCTION f_get_cbancar_seg(
      psseguro IN NUMBER,
      pfecha IN DATE,
      pcbancar OUT VARCHAR2,
      pcbancob OUT VARCHAR2)
      RETURN NUMBER IS
      v_query        VARCHAR2(1000);
      vobject        VARCHAR2(200) := 'PAC_CBANCAR_SEG.F_GET_CBANCAR_SEGHIS';
      mensajes       t_iax_mensajes;
      presult        sys_refcursor;
      e_param_error  EXCEPTION;
      e_object_error EXCEPTION;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(900)
         := 'F_GET_CBANCAR_SEG PARAMETROS: SSEGURO=' || psseguro || ',PFECHA = '
            || TO_CHAR(pfecha, 'dd/mm/yyyy');
   BEGIN
      -- Bug 10890 - RSC - 10/08/2009 - APR - error en el mto. de cuenta de cargo
      --SELECT segb.cbancar, segb.cbancob
      --  INTO pcbancar, pcbancob
      -- FROM seg_cbancar segb
      -- WHERE segb.sseguro = psseguro
      --   AND(TO_DATE(TO_CHAR(pfecha, 'dd/mm/yyyy'), 'dd/mm/yyyy') BETWEEN segb.finiefe
      --                                                                AND segb.ffinefe);
      SELECT segb.cbancar, segb.cbancob
        INTO pcbancar, pcbancob
        FROM seg_cbancar segb
       WHERE segb.sseguro = psseguro
         AND pfecha >= finiefe
         AND(pfecha < ffinefe
             OR ffinefe IS NULL);

      -- Fin Bug 10890
      RETURN 0;
   EXCEPTION
      -- Bug 0013779 - XPL - 23/03/2010 - APR - 0013779: domiciliation - no record
      WHEN NO_DATA_FOUND THEN
         p_tab_error(f_sysdate, f_user, 'PAC_CBANCAR_SEG', 2,
                     'PAC_CBANCAR_SEG.F_GET_CBANCAR_SEG' || 102903, SQLERRM);
         RETURN 0;
      -- Fin Bug 0013779
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_CBANCAR_SEG', 2,
                     'PAC_CBANCAR_SEG.F_GET_CBANCAR_SEG' || 102903, SQLERRM);
         RETURN 102903;
   END f_get_cbancar_seg;

   /*************************************************************************
       La función se encarga de grabar los datos de la cuenta de cargo
       param in PSSEGURO : código seguro
       param in PCBANCOB : cuenta de cobro
    *************************************************************************/
   FUNCTION f_set_cbancar_seg(psseguro IN NUMBER, pcbancob IN VARCHAR2)
      RETURN NUMBER IS
      v_csseguro     NUMBER := 0;
      v_nmovimi      movseguro.nmovimi%TYPE;
      v_error        NUMBER;
      pncontrol      NUMBER;
      pnsalida       VARCHAR2(50);
   BEGIN
      SELECT COUNT(*)
        INTO v_csseguro
        FROM seg_cbancar
       WHERE sseguro = psseguro;

      IF v_csseguro <> 0 THEN
         --Se actualiza para el Sseguro el movimiento con el Cbancob vacio
         SELECT nmovimi
           INTO v_nmovimi
           FROM seg_cbancar
          WHERE sseguro = psseguro
            --AND cbancob IS NULL;
            AND ffinefe IS NULL;   -- Bug 10890 - RSC - 10/08/2009 - APR - error en el mto. de cuenta de cargo

         IF v_nmovimi IS NOT NULL THEN
            v_error := f_ccc(pcbancob, 4, pncontrol, pnsalida);

            IF v_error = 0 THEN
               UPDATE seg_cbancar
                  SET cbancob = pcbancob
                WHERE sseguro = psseguro
                  AND nmovimi = v_nmovimi;

               COMMIT;
            ELSE
               RETURN v_error;
            END IF;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_CBANCAR_SEG', 3,
                     'PAC_CBANCAR_SEG.F_SET_CBANCAR_SEG' || 9000777, SQLERRM);
         RETURN 9000777;
   END f_set_cbancar_seg;

   /***********************************************************************
         Formatea la cuenta bancaria
         param in ctipban : tipo cuenta
         param in cbancar : cuenta bancaria
         return           : cuenta formateada si ha podido aplicar el formato
                            sino devuelve la cuenta
      ***********************************************************************/
   FUNCTION ff_formatccc(ctipban IN NUMBER, cbancar IN VARCHAR2)
      RETURN VARCHAR2 IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'ctipban=' || ctipban || ' cbancar=' || cbancar;
      vobject        VARCHAR2(200) := 'PAC_CBANCAR_SEG.FF_FormatCCC';
      RESULT         VARCHAR2(500);
      nerr           NUMBER;
      mensajes       t_iax_mensajes;
   BEGIN
      nerr := f_formatoccc(cbancar, RESULT, ctipban);

      IF RESULT IS NULL THEN
         RETURN cbancar;
      END IF;

      RETURN RESULT;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_CBANCAR_SEG', 3,
                     'PAC_CBANCAR_SEG.FF_FormatCCC' || 1000135, SQLERRM);   --el formato de campo
         RETURN(NULL);
   END ff_formatccc;
END pac_cbancar_seg;

/

  GRANT EXECUTE ON "AXIS"."PAC_CBANCAR_SEG" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_CBANCAR_SEG" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_CBANCAR_SEG" TO "PROGRAMADORESCSI";
