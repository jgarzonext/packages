--------------------------------------------------------
--  DDL for Package Body PAC_MD_PORCEN_PMD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MD_PORCEN_PMD" IS
      /******************************************************************************
        NOMBRE:       PAC_MD_PORCEN_PMD
        COMPANIAS
      PROP¿¿SITO: Funciones para gestionar PMD

      REVISIONES:
      Ver        Fecha        Autor       Descripci¿¿n
      ---------  ----------  ---------  ------------------------------------
      1.0        11/03/2014  AGG        1. Creaci¿¿n del package.
   ******************************************************************************/

   -------------------------------------------------------------------------------------------------------------------------------
   PROCEDURE p_agrega_where(p_where IN OUT VARCHAR2, p_add IN VARCHAR2) IS
   BEGIN
      IF p_where IS NOT NULL THEN
         p_where := p_where || ' and ';
      END IF;

      p_where := p_where || p_add;
   END p_agrega_where;

   /*************************************************************************
    Funci¿n que se encarga de comprobar si la fecha es superior o inferior a la
    fecha de inicio o de fin de contrato en cada caso

    pbmayor : false Menor , true Mayor
    return              : 0 Ok. 1 Error
   *************************************************************************/
   FUNCTION f_comprueba_fecha_fcontrato(
      pscontra IN ctto_tramo_producto.scontra%TYPE,
      pnversio IN ctto_tramo_producto.nversio%TYPE,
      pfecha IN DATE,
      pbmayor IN BOOLEAN,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_fconini      contratos.fconini%TYPE;
      v_fconfin      contratos.fconfin%TYPE;
   BEGIN
      p_tab_error(f_sysdate, f_user, 'f_set_porcen_tramo_ctto', 33,
                  'entra comprueba fecha fcontrato', NULL);

      SELECT fconini, fconfin
        INTO v_fconini, v_fconfin
        FROM contratos
       WHERE scontra = pscontra
         AND nversio = pnversio;

      IF pbmayor THEN
         IF pfecha > v_fconfin THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 0, 9906771);
            RETURN 9906771;
         END IF;
      ELSE
         IF pfecha < v_fconini THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 0, 9906772);
            RETURN 9906772;
         END IF;
      END IF;

      RETURN 0;
   END f_comprueba_fecha_fcontrato;

   FUNCTION f_hay_fecha_pago_mes(
      pidcabecera IN porcen_tramo_ctto.idcabecera%TYPE,
      pfecha IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      tporcen        t_iax_porcen_tramo_ctto := t_iax_porcen_tramo_ctto();
      v_mesfpago     NUMBER := 0;
      v_anyofpago    NUMBER := 0;
      v_mes          NUMBER := 0;
      v_anyo         NUMBER := 0;
   BEGIN
      tporcen := f_get_porcentajes_tramo_ctto(pidcabecera, mensajes);
      v_mes := EXTRACT(MONTH FROM pfecha);
      v_anyo := EXTRACT(YEAR FROM pfecha);

      IF tporcen.COUNT > 0 THEN
         FOR i IN tporcen.FIRST .. tporcen.LAST LOOP
            v_mesfpago := EXTRACT(MONTH FROM tporcen(i).fpago);
            v_anyofpago := EXTRACT(YEAR FROM tporcen(i).fpago);

            IF (v_mesfpago = v_mes)
               AND(v_anyofpago = v_anyo) THEN
               RETURN 1;
            ELSE
               RETURN 0;
            END IF;
         END LOOP;
      ELSE
         RETURN 0;
      END IF;
   END f_hay_fecha_pago_mes;

   /*************************************************************************
      Nueva funci¿¿n que se encarga de borrar un registro de ctto_tramo_producto
      return              : 0 Ok. 1 Error
     *************************************************************************/
   FUNCTION f_del_ctto_tramo_producto(
      pid IN ctto_tramo_producto.ID%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_result       NUMBER := 1;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'par¿metros - pid = ' || pid;
      vobject        VARCHAR2(200) := 'PAC_MD_PORCEN_PMD.f_del_ctto_tramo_producto';
      v_fich         VARCHAR2(400);
   BEGIN
      vpasexec := 1;

      IF pid IS NULL THEN
         RETURN -1;
      ELSE
         DELETE      porcen_tramo_ctto
               WHERE idcabecera = pid;

         DELETE      ctto_tramo_producto
               WHERE ID = pid;

         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 0, 111313);
         RETURN 0;
      END IF;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN -1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN -1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN -1;
   END f_del_ctto_tramo_producto;

   /*************************************************************************
      Nueva funci¿¿n que se encarga de borrar un registro de porcen_tramo_ctto
      return              : 0 Ok. 1 Error
   *************************************************************************/
   FUNCTION f_del_porcen_tramo_ctto(
      pidcabecera IN porcen_tramo_ctto.idcabecera%TYPE,
      pid IN porcen_tramo_ctto.ID%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_result       NUMBER := 1;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
                           := 'par¿metros - pid = ' || pid || ' pidcabecera = ' || pidcabecera;
      vobject        VARCHAR2(200) := 'PAC_MD_PORCEN_PMD.f_del_porcen_tramo_ctto';
      v_fich         VARCHAR2(400);
      ntotal         NUMBER := 0;
   BEGIN
      vpasexec := 1;

      IF pidcabecera IS NULL
         AND pid IS NULL THEN
         RETURN -1;
      ELSE
         IF pidcabecera IS NOT NULL
            AND pid IS NULL THEN
            DELETE      porcen_tramo_ctto
                  WHERE idcabecera = pidcabecera;
         ELSIF pid IS NOT NULL
               AND pidcabecera IS NULL THEN
            DELETE      porcen_tramo_ctto
                  WHERE ID = pid;
         ELSE
            DELETE      porcen_tramo_ctto
                  WHERE idcabecera = pidcabecera
                    AND ID = pid;
         END IF;

         BEGIN
            SELECT SUM(porcen)
              INTO ntotal
              FROM porcen_tramo_ctto
             WHERE idcabecera = pidcabecera;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               ntotal := 0;
         END;

         UPDATE ctto_tramo_producto
            SET porcen = NVL(ntotal, 0)
          WHERE ID = pidcabecera;

         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 0, 111313);
         RETURN 0;
      END IF;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN -1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN -1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN -1;
   END f_del_porcen_tramo_ctto;

   /*************************************************************************
    Nueva funci¿¿n que se encarga de insertar un registro de ctto_tramo_producto
    return              : 0 Ok. 1 Error
   *************************************************************************/
   FUNCTION f_set_ctto_tramo_producto(
      pnid IN OUT ctto_tramo_producto.ID%TYPE,
      pscontra IN ctto_tramo_producto.scontra%TYPE,
      pnversio IN ctto_tramo_producto.nversio%TYPE,
      pctramo IN ctto_tramo_producto.ctramo%TYPE,
      pcramo IN ctto_tramo_producto.cramo%TYPE,
      psproduc IN ctto_tramo_producto.sproduc%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_result       NUMBER(1) := 1;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
         := 'par¿¿metros - pscontra:' || pscontra || ' pnversio: ' || pnversio || ' pctramo: '
            || pctramo || ' pcramo: ' || ' psproduc: ' || psproduc;
      vobject        VARCHAR2(200) := 'pac_md_porcen_pmd.f_set_ctto_tramo_producto';
      v_nerror       NUMBER;
      v_host         VARCHAR2(10);
      vcterminal     usuarios.cterminal%TYPE;
      vsinterf       NUMBER;
      vterror        VARCHAR(2000);
      vid            NUMBER;
      v_num          NUMBER := 0;
   BEGIN
      vpasexec := 1;
      p_tab_error(f_sysdate, f_user, vobject, vpasexec, NULL, NULL);

      --Comprovem els parametres d'entrada.
      IF (pscontra IS NULL)
         OR(pnversio IS NULL)
         OR(pctramo IS NULL)
         OR(pcramo IS NULL) THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;

      BEGIN
         SELECT COUNT(1)
           INTO v_num
           FROM ctto_tramo_producto
          WHERE scontra = pscontra
            AND nversio = pnversio
            AND ctramo = pctramo
            AND cramo = pcramo
            AND sproduc = psproduc;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            v_num := 0;
      END;

      IF v_num = 0 THEN
         SELECT sidctto_tramo_producto.NEXTVAL
           INTO vid
           FROM DUAL;

         pnid := vid;
         vpasexec := 3;

         INSERT INTO ctto_tramo_producto
                     (ID, scontra, nversio, ctramo, cramo, sproduc, porcen, falta, cusualta)
              VALUES (vid, pscontra, pnversio, pctramo, pcramo, psproduc, 0, f_sysdate, f_user);

         p_tab_error(f_sysdate, f_user, vobject, vpasexec, NULL, NULL);
      ELSE
         vpasexec := 4;

         UPDATE ctto_tramo_producto
            SET scontra = pscontra,
                nversio = pnversio,
                ctramo = pctramo,
                cramo = pcramo,
                sproduc = psproduc,
                cusumod = f_user
          WHERE scontra = pscontra
            AND nversio = pnversio
            AND ctramo = pctramo
            AND cramo = pcramo
            AND sproduc = psproduc;

         SELECT ID
           INTO pnid
           FROM ctto_tramo_producto
          WHERE scontra = pscontra
            AND nversio = pnversio
            AND ctramo = pctramo
            AND cramo = pcramo
            AND sproduc = psproduc;

         p_tab_error(f_sysdate, f_user, vobject, vpasexec, NULL, NULL);
      END IF;

      vpasexec := 5;
      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 0, 111313);
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN -1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN -1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN -1;
   END f_set_ctto_tramo_producto;

   /*************************************************************************
    Nueva funci¿¿n que se encarga de recuperar un registro de la tabla ctto_tramo_producto
    return              : 0 Ok. 1 Error
   *************************************************************************/
   FUNCTION f_get_ctto_tramo_producto(
      pid IN ctto_tramo_producto.ID%TYPE,
      pscontra IN ctto_tramo_producto.scontra%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN ob_iax_ctto_tramo_producto IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
                                 := 'par¿¿metros - pid = ' || pid || ' pscontra: ' || pscontra;
      vobject        VARCHAR2(200) := 'PAC_MD_PORCEN_TRAMO_CTTO.f_get_ctto_tramo_producto';
      v_fich         VARCHAR2(400);
      vctto_tramo_producto sys_refcursor;
      octtotramoproducto ob_iax_ctto_tramo_producto := ob_iax_ctto_tramo_producto();
      v_numerr       NUMBER;
      v_tnombre      VARCHAR2(100);
      vsquery        VARCHAR2(9000);
      v_where        VARCHAR2(4000);

      CURSOR ccttotramoproducto IS
         SELECT co.tcontra AS descontra, r.tramo AS descramo, tit.ttitulo AS descproducto,
                ff_desvalorfijo(105, pac_md_common.f_get_cxtidioma(), c.ctramo) AS desctramo,
                c.*
           FROM contratos co, ramos r, ctto_tramo_producto c LEFT OUTER JOIN productos p
                ON c.sproduc = p.sproduc
                LEFT OUTER JOIN titulopro tit
                ON p.cramo = tit.cramo
              AND p.cmodali = tit.cmodali
              AND p.ctipseg = tit.ctipseg
              AND p.ccolect = tit.ccolect
              AND tit.cidioma = pac_md_common.f_get_cxtidioma()
          WHERE c.scontra = co.scontra
            AND c.nversio = co.nversio
            AND c.cramo = r.cramo
            AND r.cidioma = pac_md_common.f_get_cxtidioma()
            AND ID = pid;

      CURSOR ccttotramoproducto2 IS
         SELECT co.tcontra AS descontra, r.tramo AS descramo, tit.ttitulo AS descproducto,
                ff_desvalorfijo(105, pac_md_common.f_get_cxtidioma(), c.ctramo) AS desctramo,
                c.*
           FROM contratos co, ramos r, ctto_tramo_producto c LEFT OUTER JOIN productos p
                ON c.sproduc = p.sproduc
                LEFT OUTER JOIN titulopro tit
                ON p.cramo = tit.cramo
              AND p.cmodali = tit.cmodali
              AND p.ctipseg = tit.ctipseg
              AND p.ccolect = tit.ccolect
              AND tit.cidioma = pac_md_common.f_get_cxtidioma()
          WHERE c.scontra = co.scontra
            AND c.nversio = co.nversio
            AND c.cramo = r.cramo
            AND r.cidioma = pac_md_common.f_get_cxtidioma()
            AND c.scontra = pscontra;

      CURSOR ccttotramoproducto3 IS
         SELECT co.tcontra AS descontra, r.tramo AS descramo, tit.ttitulo AS descproducto,
                ff_desvalorfijo(105, pac_md_common.f_get_cxtidioma(), c.ctramo) AS desctramo,
                c.*
           FROM contratos co, ramos r, ctto_tramo_producto c LEFT OUTER JOIN productos p
                ON c.sproduc = p.sproduc
                LEFT OUTER JOIN titulopro tit
                ON p.cramo = tit.cramo
              AND p.cmodali = tit.cmodali
              AND p.ctipseg = tit.ctipseg
              AND p.ccolect = tit.ccolect
              AND tit.cidioma = pac_md_common.f_get_cxtidioma()
          WHERE c.scontra = co.scontra
            AND c.nversio = co.nversio
            AND c.cramo = r.cramo
            AND r.cidioma = pac_md_common.f_get_cxtidioma()
            AND c.scontra = pscontra
            AND ID = pid;
   BEGIN
      vpasexec := 1;

      IF pid IS NULL
         AND pscontra IS NULL THEN
         RETURN NULL;
      END IF;

      vpasexec := 2;

      IF pscontra IS NOT NULL
         AND pid IS NOT NULL THEN
         FOR ctto IN ccttotramoproducto3 LOOP
            octtotramoproducto.ID := ctto.ID;
            octtotramoproducto.scontra := ctto.scontra;
            octtotramoproducto.nversio := ctto.nversio;
            octtotramoproducto.ctramo := ctto.ctramo;
            octtotramoproducto.cramo := ctto.cramo;
            octtotramoproducto.sproduc := ctto.sproduc;
            octtotramoproducto.porcen := ctto.porcen;
            octtotramoproducto.desccontra := ctto.descontra;
            octtotramoproducto.descramo := ctto.descramo;
            octtotramoproducto.descproducto := ctto.descproducto;
            octtotramoproducto.desctramo := ctto.desctramo;
         END LOOP;
      ELSE
         IF pscontra IS NULL THEN
            FOR ctto IN ccttotramoproducto LOOP
               octtotramoproducto.ID := ctto.ID;
               octtotramoproducto.scontra := ctto.scontra;
               octtotramoproducto.nversio := ctto.nversio;
               octtotramoproducto.ctramo := ctto.ctramo;
               octtotramoproducto.cramo := ctto.cramo;
               octtotramoproducto.sproduc := ctto.sproduc;
               octtotramoproducto.porcen := ctto.porcen;
               octtotramoproducto.desccontra := ctto.descontra;
               octtotramoproducto.descramo := ctto.descramo;
               octtotramoproducto.descproducto := ctto.descproducto;
               octtotramoproducto.desctramo := ctto.desctramo;
            END LOOP;
         ELSE
            FOR ctto IN ccttotramoproducto2 LOOP
               octtotramoproducto.ID := ctto.ID;
               octtotramoproducto.scontra := ctto.scontra;
               octtotramoproducto.nversio := ctto.nversio;
               octtotramoproducto.ctramo := ctto.ctramo;
               octtotramoproducto.cramo := ctto.cramo;
               octtotramoproducto.sproduc := ctto.sproduc;
               octtotramoproducto.porcen := ctto.porcen;
               octtotramoproducto.desccontra := ctto.descontra;
               octtotramoproducto.descramo := ctto.descramo;
               octtotramoproducto.descproducto := ctto.descproducto;
               octtotramoproducto.desctramo := ctto.desctramo;
               vpasexec := 3;
            END LOOP;
         END IF;
      END IF;

      RETURN octtotramoproducto;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN octtotramoproducto;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN octtotramoproducto;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN octtotramoproducto;
   END f_get_ctto_tramo_producto;

   /*************************************************************************
     Nueva funci¿¿n que se encarga de recuperar los registros de ctto_tramo_producto
     return              : 0 Ok. 1 Error
    *************************************************************************/
   FUNCTION f_get_cttostramosproductos(
      pscontra IN ctto_tramo_producto.scontra%TYPE,
      pnversio IN NUMBER,
      pnramo IN NUMBER,
      pntramo IN NUMBER,
      pnproduc IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN t_iax_ctto_tramo_producto IS
      CURSOR cttostramoproducto IS
         SELECT   *
             FROM ctto_tramo_producto
         ORDER BY ID;

      vtcttotramoproducto t_iax_ctto_tramo_producto := t_iax_ctto_tramo_producto();
      vobcttotramoproducto ob_iax_ctto_tramo_producto := ob_iax_ctto_tramo_producto();
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := '';
      vobject        VARCHAR2(200) := 'PAC_MD_PORCEN_PMD.f_get_cttostramosproductos';
      vsquery        VARCHAR2(9000);
      v_where        VARCHAR2(4000);
      vcursor        sys_refcursor;
      vcont          NUMBER := 0;
   BEGIN
      p_tab_error(f_sysdate, f_user, 'pac_md_porcen_pmd.f_get_cttostramosproductos', 22,
                  'entra', NULL);
      vsquery :=
         'SELECT c.id, c.scontra, c.nversio, c.ctramo, c.cramo, c.sproduc, c.porcen,
          co.tcontra AS descontra, r.tramo AS descramo, tit.ttitulo AS descproducto,
                ff_desvalorfijo(105, pac_md_common.f_get_cxtidioma(), c.ctramo) AS desctramo

           FROM contratos co, ramos r, ctto_tramo_producto c LEFT OUTER JOIN productos p
                ON c.sproduc = p.sproduc
                LEFT OUTER JOIN titulopro tit
                ON p.cramo = tit.cramo
              AND p.cmodali = tit.cmodali
              AND p.ctipseg = tit.ctipseg
              AND p.ccolect = tit.ccolect
              AND tit.cidioma = pac_md_common.f_get_cxtidioma()';
      p_agrega_where(v_where, 'c.scontra = co.scontra');
      p_agrega_where(v_where, 'c.nversio = co.nversio');
      p_agrega_where(v_where, 'c.cramo = r.cramo');
      p_agrega_where(v_where, 'r.cidioma = pac_md_common.f_get_cxtidioma()');
      --vsquery := 'select c.id, c.scontra, c.nversio, c.ctramo, c.cramo, c.sproduc, c.porcen, ''descramo'' as descramo, ''producto'' as descproducto, ''tramo'' as desctramo from ctto_tramo_producto c';
      --vsquery := 'select c.id, c.scontra from ctto_tramo_producto c';
      vpasexec := 3;
      p_tab_error(f_sysdate, f_user, 'pac_md_porcen_pmd', 22, 'despues', NULL);

      IF pscontra IS NOT NULL THEN
         p_agrega_where(v_where, 'c.scontra = ' || pscontra);
      END IF;

      IF pnversio IS NOT NULL THEN
         p_agrega_where(v_where, 'c.nversio = ' || pnversio);
      END IF;

      vpasexec := 4;

      IF pnramo IS NOT NULL THEN
         p_agrega_where(v_where, 'c.cramo = ' || pnramo);
      END IF;

      vpasexec := 5;

      IF pntramo IS NOT NULL THEN
         p_agrega_where(v_where, 'c.ctramo = ' || pntramo);
      END IF;

      vpasexec := 6;

      IF pnproduc IS NOT NULL THEN
         p_agrega_where(v_where, 'c.sproduc = ' || pnproduc);
      END IF;

      vpasexec := 7;

      IF v_where IS NOT NULL THEN
         vsquery := vsquery || ' where ' || v_where;
      END IF;

      vpasexec := 8;
      vcursor := pac_iax_listvalores.f_opencursor(vsquery, mensajes);
      p_tab_error(f_sysdate, f_user, 'f_set_porcen_tramo_ctto', 33, 'DESPUES F_OPENCURSOR',
                  NULL);
      vpasexec := 9;

      --planpensiones := t_iax_planpensiones();
      LOOP
         --c.id, c.scontra, c.nversio, c.ctramo, c.cramo, c.sproduc, c.porcen, ''descramo'' as descramo, ''producto'' as descproducto, ''tramo'' as desctramo
         FETCH vcursor
          INTO vobcttotramoproducto.ID, vobcttotramoproducto.scontra,
               vobcttotramoproducto.nversio, vobcttotramoproducto.ctramo,
               vobcttotramoproducto.cramo, vobcttotramoproducto.sproduc,
               vobcttotramoproducto.porcen, vobcttotramoproducto.desccontra,
               vobcttotramoproducto.descramo, vobcttotramoproducto.descproducto,
               vobcttotramoproducto.desctramo;

         p_tab_error(f_sysdate, f_user, 'f_set_porcen_tramo_ctto', 33, 'despues fetch into',
                     NULL);
         vcont := vcont + 1;
         EXIT WHEN vcursor%NOTFOUND;
         vtcttotramoproducto.EXTEND;
         vtcttotramoproducto(vtcttotramoproducto.LAST) := vobcttotramoproducto;
         vobcttotramoproducto := ob_iax_ctto_tramo_producto();
      END LOOP;

      CLOSE vcursor;

      /*IF NOT vcursor%ISOPEN
         OR vcursor%NOTFOUND THEN
         -- Se ha producido un error
         p_tab_error(f_sysdate, f_user, 'f_set_porcen_tramo_ctto', 33,
                     'SE HA PRODUCIDO UN ERROR', NULL);
         RAISE e_object_error;
      END IF;*/
      p_tab_error(f_sysdate, f_user, 'f_set_porcen_tramo_ctto', 33, 'cuarto', NULL);
      RETURN vtcttotramoproducto;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, '1 ' || vobject, 1000005, vpasexec,
                                           vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, '2 ' || vobject, 1000006, vpasexec,
                                           vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, '3 ' || vobject, 1000001, vpasexec,
                                           vparam, psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_cttostramosproductos;

    /*************************************************************************
    Funci¿n que se encarga de recuperar el porcentaje de la cuota
    return              : 0 Ok. 1 Error
   *************************************************************************/
   FUNCTION f_get_porcen_tramo_ctto(
      pidcabecera IN porcen_tramo_ctto.idcabecera%TYPE,
      pid IN porcen_tramo_ctto.ID%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN ob_iax_porcen_tramo_ctto IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
                            := 'par¿metros - pidcabecera = ' || pidcabecera || ' pid: ' || pid;
      vobject        VARCHAR2(200) := 'PAC_MD_PORCEN_PMD.f_get_porcen_tramo_ctto';
      v_fich         VARCHAR2(400);
      vporcentramo   sys_refcursor;
      porcen_tramo   ob_iax_porcen_tramo_ctto := ob_iax_porcen_tramo_ctto();
      v_numerr       NUMBER;
      v_tnombre      VARCHAR2(100);

      CURSOR cporcentramoctto IS
         SELECT *
           FROM porcen_tramo_ctto
          WHERE idcabecera = pidcabecera
            AND ID = pid;
   BEGIN
      vpasexec := 1;

      IF pidcabecera IS NULL
         AND pid IS NULL THEN
         RETURN NULL;
      END IF;

      vpasexec := 2;

      FOR ind IN cporcentramoctto LOOP
         porcen_tramo.idcabecera := ind.idcabecera;
         porcen_tramo.ID := ind.ID;
         porcen_tramo.porcen := ind.porcen;
         porcen_tramo.fpago := ind.fpago;
         vpasexec := 3;
      END LOOP;

      RETURN porcen_tramo;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN porcen_tramo;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN porcen_tramo;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN porcen_tramo;
   END f_get_porcen_tramo_ctto;

   /*************************************************************************
     Funci¿n que se encarga de recuperar los porcentajes de las cuotas
     return              : 0 Ok. 1 Error
    *************************************************************************/
   FUNCTION f_get_porcentajes_tramo_ctto(
      pidcabecera IN porcen_tramo_ctto.ID%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN t_iax_porcen_tramo_ctto IS
      CURSOR porcentramos IS
         SELECT   *
             FROM porcen_tramo_ctto
            WHERE idcabecera = pidcabecera
         ORDER BY idcabecera, ID;

      vtporcentramoctto t_iax_porcen_tramo_ctto := t_iax_porcen_tramo_ctto();
      vobporcentramoctto ob_iax_porcen_tramo_ctto := ob_iax_porcen_tramo_ctto();
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := '';
      vobject        VARCHAR2(200) := 'PAC_MD_PORCEN_PMD.f_get_porcentajes_tramo_ctto';
   BEGIN
      vpasexec := 1;

      FOR ind IN porcentramos LOOP
         vobporcentramoctto := pac_md_porcen_pmd.f_get_porcen_tramo_ctto(ind.idcabecera,
                                                                         ind.ID, mensajes);
         vtporcentramoctto.EXTEND;
         vtporcentramoctto(vtporcentramoctto.LAST) := vobporcentramoctto;
         vobporcentramoctto := ob_iax_porcen_tramo_ctto();
      END LOOP;

      RETURN vtporcentramoctto;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_porcentajes_tramo_ctto;

   /*************************************************************************
    Funci¿n que se encarga de insertar un registro en porcen_tramo
    return              : 0 Ok. 1 Error
   *************************************************************************/
   FUNCTION f_set_porcen_tramo_ctto(
      pidcabecera IN porcen_tramo_ctto.idcabecera%TYPE,
      pid IN porcen_tramo_ctto.ID%TYPE,
      pporcen IN porcen_tramo_ctto.porcen%TYPE,
      pfpago IN porcen_tramo_ctto.fpago%TYPE,
      pnreplica IN VARCHAR2 DEFAULT 0,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_result       NUMBER(1) := 1;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
         := 'par¿¿metros - pidcabecera:' || pidcabecera || ' pid: ' || pid || ' pporcen: '
            || pporcen;
      vobject        VARCHAR2(200) := 'PAC_MD_PORCEN_PMD.f_set_porcen_tramo_ctto';
      vterror        VARCHAR(2000);
      v_nerror       NUMBER;
      v_insertados   NUMBER := 0;
      v_nversio      ctto_tramo_producto.nversio%TYPE;
      v_scontra      ctto_tramo_producto.scontra%TYPE;
      v_ctramo       ctto_tramo_producto.ctramo%TYPE;
      v_cfrepmd      tramos.cfrepmd%TYPE;
      v_reg          NUMBER := 0;
      ntotal         NUMBER := 0;
      ntotalcuota    NUMBER := 0;
   BEGIN
      vpasexec := 1;
      p_tab_error(f_sysdate, f_user, 'f_set_porcen_tramo_ctto', 33, 'primero', NULL);

      BEGIN
         SELECT SUM(porcen)
           INTO ntotal
           FROM porcen_tramo_ctto
          WHERE idcabecera = pidcabecera;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            ntotal := 0;
      END;

      BEGIN
         SELECT porcen
           INTO ntotalcuota
           FROM porcen_tramo_ctto
          WHERE idcabecera = pidcabecera
            AND ID = pid;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            ntotalcuota := 0;
      END;

      ntotal := (ntotal - ntotalcuota) + pporcen;
      p_tab_error(f_sysdate, f_user, 'f_set_porcen_tramo_ctto', 33, 'segundo', NULL);

      IF ntotal > 100 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 0, 9906706);
         RETURN 9906706;   --se ha alcanzado el 100% de la cuota, ya no se pueden insertar m¿s
      END IF;

      p_tab_error(f_sysdate, f_user, 'f_set_porcen_tramo_ctto', 33,
                  'segundo .1 pidcabecera: ' || pidcabecera, NULL);

      SELECT nversio, scontra, ctramo
        INTO v_nversio, v_scontra, v_ctramo
        FROM ctto_tramo_producto
       WHERE ID = pidcabecera;

      p_tab_error(f_sysdate, f_user, 'f_set_porcen_tramo_ctto', 33, 'segundo .2', NULL);
      v_nerror := f_comprueba_fecha_fcontrato(v_scontra, v_nversio, pfpago, TRUE, mensajes);
      p_tab_error(f_sysdate, f_user, 'f_set_porcen_tramo_ctto', 33, 'tercero', NULL);

      IF v_nerror > 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 0, 99067731);
         RETURN 9906701;
      END IF;

      v_nerror := f_comprueba_fecha_fcontrato(v_scontra, v_nversio, pfpago, FALSE, mensajes);
      p_tab_error(f_sysdate, f_user, 'f_set_porcen_tramo_ctto', 33, 'cuarto', NULL);

      IF v_nerror > 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 0, 99067732);
         RETURN 9906702;
      END IF;

      v_nerror := f_hay_fecha_pago_mes(pidcabecera, pfpago, mensajes);
      p_tab_error(f_sysdate, f_user, 'f_set_porcen_tramo_ctto', 33,
                  'quinto vnerror: ' || v_nerror, NULL);

      IF v_nerror > 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 0, 9906773);
         RETURN 9906773;
      END IF;

      p_tab_error(f_sysdate, f_user, 'f_set_porcen_tramo_ctto', 33, 'sexto', NULL);

      BEGIN
         SELECT COUNT(1)
           INTO v_reg
           FROM porcen_tramo_ctto
          WHERE idcabecera = pidcabecera
            AND ID = pid;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            v_reg := 0;
      END;

      p_tab_error(f_sysdate, f_user, 'f_set_porcen_tramo_ctto', 33, 'septimo', NULL);

      IF v_reg > 0 THEN
         vpasexec := 3;

         --Estamos modificando
         UPDATE porcen_tramo_ctto
            SET porcen = pporcen,
                cusumod = f_user,
                fpago = pfpago
          WHERE idcabecera = pidcabecera
            AND ID = pid;

         BEGIN
            SELECT SUM(porcen)
              INTO ntotal
              FROM porcen_tramo_ctto
             WHERE idcabecera = pidcabecera;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               ntotal := 0;
         END;

         UPDATE ctto_tramo_producto
            SET porcen = ntotal
          WHERE ID = pidcabecera;
      ELSE
         vpasexec := 4;
         p_tab_error(f_sysdate, f_user, 'f_set_porcen_tramo_ctto', 33, 'primero insert', NULL);

         BEGIN
            SELECT COUNT(*)
              INTO v_insertados
              FROM porcen_tramo_ctto
             WHERE idcabecera = pidcabecera;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               v_insertados := 0;
         END;

         BEGIN
            SELECT NVL(cfrepmd, 0)
              INTO v_cfrepmd
              FROM tramos
             WHERE nversio = v_nversio
               AND scontra = v_scontra
               AND ctramo = v_ctramo;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               RETURN -1;   --ERROR no podemos estar insertando el registro en porcen_tramo_ctto sin que est¿ en ctto_tramo_producto
         END;

         IF (v_insertados >= v_cfrepmd) THEN
            --Ya se han insertados todas las cuotas, no se pueden insertar m¿s
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 0, 9906622);
            RETURN 9906622;
         END IF;

         --Estamos insertando
         p_tab_error(f_sysdate, f_user, 'f_set_porcen_tramo_ctto', 55, 'antes insert', NULL);

         INSERT INTO porcen_tramo_ctto
                     (idcabecera, ID, porcen, nreplicada, falta, cusualta,
                      fpago)
              VALUES (pidcabecera,(v_insertados + 1), pporcen, pnreplica, f_sysdate, f_user,
                      pfpago);

         p_tab_error(f_sysdate, f_user, 'f_set_porcen_tramo_ctto', 56, 'despues insert', NULL);

         BEGIN
            SELECT SUM(porcen)
              INTO ntotal
              FROM porcen_tramo_ctto
             WHERE idcabecera = pidcabecera;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               ntotal := 0;
         END;

         UPDATE ctto_tramo_producto
            SET porcen = ntotal
          WHERE ID = pidcabecera;
      END IF;

      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 0, 111313);
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN -1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN -1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN -1;
   END f_set_porcen_tramo_ctto;

   /*************************************************************************
    Funci¿n que se encarga de copiar la configuraci¿n de un contrato a partir de
    la configuraci¿n de otro del mismo ramo
    return              : 0 Ok. 1 Error
   *************************************************************************/
   FUNCTION f_copiar_config_producto(
      pcramo IN ctto_tramo_producto.cramo%TYPE,
      psproduc IN ctto_tramo_producto.sproduc%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      CURSOR cur IS
         SELECT *
           FROM ctto_tramo_producto
          WHERE cramo = pcramo
            AND sproduc = psproduc;

      CURSOR prod_ramos IS
         SELECT DISTINCT sproduc
                    FROM productos
                   WHERE cramo = pcramo
                     AND sproduc <> psproduc
                     AND cactivo = 1;

      nerr           NUMBER := 0;
      vpasexec       NUMBER := 0;
      vparam         VARCHAR2(2000)
                               := 'par¿metros - pcramo:' || pcramo || ' psproduc: ' || psproduc;
      vobject        VARCHAR2(200) := 'PAC_MD_PORCEN_PMD.f_copiar_config_producto';
      vid            NUMBER;
   BEGIN
      FOR c IN cur LOOP
         FOR prod IN prod_ramos LOOP
            vpasexec := 1;
            vid := c.ID;
            nerr := f_set_ctto_tramo_producto(vid, c.scontra, c.nversio, c.ctramo, c.cramo,
                                              prod.sproduc, mensajes);
            vpasexec := 2;
         END LOOP;
      END LOOP;

      IF nerr = 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 0, 111313);
      END IF;

      RETURN nerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN -1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN -1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN -1;
   END f_copiar_config_producto;

   /*************************************************************************
    Funci¿n que se encarga de replicar las cuotas para todos los productos configurados
    correspondientes a un mismo contrato, tramo y ramo
    la configuraci¿n de otro del mismo ramo
    return              : 0 Ok. 1 Error
   *************************************************************************/
   FUNCTION f_replicar_cuotas(
      pscontra IN ctto_tramo_producto.scontra%TYPE,
      pctramo IN ctto_tramo_producto.ctramo%TYPE,
      pcramo IN ctto_tramo_producto.cramo%TYPE,
      psproduc IN ctto_tramo_producto.sproduc%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      CURSOR ctto(pid NUMBER) IS
         /* SELECT *
            FROM ctto_tramo_producto
           WHERE scontra = pscontra
             AND ctramo = pctramo
             AND cramo = pcramo;*/
         SELECT *
           FROM ctto_tramo_producto c
          WHERE scontra = pscontra
            AND ctramo = pctramo
            AND cramo = pcramo
            AND ID <> pid;

      CURSOR porcen(pid NUMBER) IS
         SELECT *
           FROM porcen_tramo_ctto
          WHERE idcabecera = pid;

      vidorig        NUMBER(6);
      vresult        NUMBER := 0;
      vpasexec       NUMBER := 0;
      vparam         VARCHAR2(2000)
         := 'par¿metros - pscontra:' || pscontra || ' pctramo: ' || pctramo || ' pcramo: '
            || pcramo || ' psproduc: ' || psproduc;
      vobject        VARCHAR2(200) := 'PAC_MD_PORCEN_PMD.f_replicar_cuotas';
      v_num_noreplicada NUMBER := 0;
      bprimeravez    BOOLEAN := FALSE;
   BEGIN
      vpasexec := 1;

      BEGIN
         SELECT ID
           INTO vidorig
           FROM ctto_tramo_producto
          WHERE scontra = pscontra
            AND ctramo = pctramo
            AND cramo = pcramo
            AND sproduc = psproduc;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            vidorig := -1;
      END;

      vpasexec := 2;

      FOR c IN ctto(vidorig) LOOP
         vpasexec := 3;

         FOR p IN porcen(vidorig) LOOP
            SELECT COUNT(1)
              INTO v_num_noreplicada
              FROM porcen_tramo_ctto
             WHERE idcabecera = c.ID
               AND nreplicada = 1;

            IF (v_num_noreplicada = 0)
               OR bprimeravez THEN
               vresult := f_set_porcen_tramo_ctto(c.ID, NULL, p.porcen, p.fpago, 1, mensajes);
               bprimeravez := TRUE;
            END IF;
         END LOOP;
      END LOOP;

      IF vresult = 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 0, 111313);
      END IF;

      RETURN vresult;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN -1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN -1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN -1;
   END f_replicar_cuotas;
END pac_md_porcen_pmd;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_PORCEN_PMD" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_PORCEN_PMD" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_PORCEN_PMD" TO "PROGRAMADORESCSI";
