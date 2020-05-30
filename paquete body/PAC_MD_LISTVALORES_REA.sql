--------------------------------------------------------
--  DDL for Package Body PAC_MD_LISTVALORES_REA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MD_LISTVALORES_REA" AS
/******************************************************************************
 NOMBRE: PAC_MD_LISTVALORES_REA
 PROPOSITO: Funciones para recuperar valores

 REVISIONES:
 Ver Fecha Autor Descripcion
 --------- ---------- --------------- ------------------------------------
 1.0                                  1. Creacion del Package
 2.0       07/10/2011 APD             2. 0019602: LCOL_A002-Correcciones en las pantallas de mantenimiento del reaseguro
 3.0       23/05/2012 AVT             3. 0022076: LCOL_A004-Mantenimientos de cuenta tecnica del reaseguro y del coaseguro
 4.0       11/02/2013 NMM             4. 23830: LCOL_A004 Ajustar el Manteniment dels Comptes de Reasseguranca (Nota: 22076/0123753)
 5.0       16/02/2013 MLR             5. 23830: LCOL_A004 Ajustar el Manteniment dels Comptes de Reasseguranca (25502/137047)
 6.0       03/05/2013 KBR             6. 25822: RSA003 - Gestion de compa¿¿ias reaseguradoras (Nota: 143771)
 7.0       15/07/2013 KBR             7. 23830: LCOL_A004 Ajustar el Manteniment dels Comptes de Reasseguranca (Nota: 140221)
 8.0       22/08/2013 DEV             8. 0026443: (POSDE400)-Desarrollo-GAPS Reaseguro, Coaseguro -Id 76 -XL capacidad prioridad dependiente del producto (Fase3)
 9.0       12/09/2013 KBR             9. 0023830: LCOL_A004 Ajustar el Manteniment dels Comptes de Reasseguranca (Nota: 152329)
 10.0      30/09/2013 RCL             10. 0023830: LCOL_A004 Ajustar el Manteniment dels Comptes de Reasseguranca (Nota: 22076/0123753)
 11.0      15/10/2013 MMM             11. 0025502 - Nota 0155491 - LCOL_T020-Qtracker: 0005655: Validacion campos pantalla facultativos
 12.0      09/04/2014 AGG             12. 0026663: POSPG400-(POSPG400)- Parametrizacion Reaseguro, Coaseguro - Parametrizacion contratos
 13.0      27/06/2014 AGG             13. 0026663: POSPG400-(POSPG400)- Parametrizacion Reaseguro, Coaseguro - Parametrizacion contratos
 14.0      22/09/2014 MMM             14. 0027104: LCOLF3BREA- ID 180 FASE 3B - Cesiones Manuales
 15.0      02/09/2016 HRE             15. CONF-250: Se incluye manejo de contratos Q1, Q2, Q3
******************************************************************************/

   /*************************************************************************
   Recupera los tipos de tramos proporcionales, devuelve un SYS_REFCURSOR
   param out : mensajes de error
   return : ref cursor
   *************************************************************************/
   FUNCTION f_get_tipostramos_prop(ctiprea NUMBER,mensajes IN OUT t_iax_mensajes)--BUG CONF-250  Fecha (02/09/2016) - HRE - se adiciona ctiprea
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      v_npasexec     NUMBER(8) := 1;
      v_tparam       VARCHAR2(1) := NULL;
      v_tobject      VARCHAR2(200) := 'PAC_MD_LISTVALORES_REA.f_get_tipostramos_prop';
      v_v_terror     VARCHAR2(200) := 'Error recuperar tipos de tramos proporcionales';
      v_tsquery      VARCHAR2(500);
   BEGIN
      --INI BUG CONF-250  Fecha (02/09/2016) - HRE - Contratos Q1, Q2, Q3
      IF ctiprea = 5 THEN
        --  cur := pac_md_listvalores.f_detvalores(8001113, mensajes);
        cur := pac_md_listvalores.f_detvalores(8002002, mensajes);
      ELSE
      --FIN BUG CONF-250  - Fecha (02/09/2016) - HRE
         cur := pac_md_listvalores.f_detvalorescond(105, 'catribu in (0,1,2,3,4,5)', mensajes);
      END IF;

      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_tobject, 1000001, v_npasexec, v_tparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_tipostramos_prop;

   /*************************************************************************
   Recupera los tipos de tramos proporcionales, devuelve un SYS_REFCURSO
   param in p_tparam : parametros de filtro
   param out : mensajes de error
   return : ref cursor
   *************************************************************************/
   FUNCTION f_get_tipostramos_prop_fil(p_tparam VARCHAR, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      v_npasexec     NUMBER(8) := 1;
      v_tparam       VARCHAR2(1) := NULL;
      v_tobject      VARCHAR2(200) := 'PAC_MD_LISTVALORES_REA.f_get_tipostramos_prop';
      v_v_terror     VARCHAR2(200) := 'Error recuperar tipos de tramos proporcionales';
      v_tsquery      VARCHAR2(500);
   BEGIN
      cur := pac_md_listvalores.f_detvalorescond_fil(105, p_tparam, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_tobject, 1000001, v_npasexec, v_tparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_tipostramos_prop_fil;

   /*************************************************************************
   Recupera los tipos de tramos NO proporcionales, devuelve un SYS_REFCURSOR
   param out : mensajes de error
   return : ref cursor
   *************************************************************************/
   FUNCTION f_get_tipostramos_noprop(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      v_npasexec     NUMBER(8) := 1;
      v_tparam       VARCHAR2(1) := NULL;
      v_tobject      VARCHAR2(200) := 'PAC_MD_LISTVALORES_REA.f_get_tipostramos_noprop';
      v_v_terror     VARCHAR2(200) := 'Error recuperar tipos de tramos no proporcionales';
      v_tsquery      VARCHAR2(500);
   BEGIN
      cur := pac_md_listvalores.f_detvalorescond(105,
                                                 'catribu in (6,7,8,9,10,11,12,13,14,15)',
                                                 mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_tobject, 1000001, v_npasexec, v_tparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_tipostramos_noprop;

   /*************************************************************************
   Recupera los tipos de E/R cartera de primas, devuelve un SYS_REFCURSOR
   param out : mensajes de error
   return : ref cursor
   *************************************************************************/
   FUNCTION f_get_ercarteraprimas(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      v_npasexec     NUMBER(8) := 1;
      v_tparam       VARCHAR2(1) := NULL;
      v_tobject      VARCHAR2(200) := 'PAC_MD_LISTVALORES_REA.F_Get_ercarteraprimas';
      v_v_terror     VARCHAR2(200) := 'Error recuperar tipos de E/R cartera de primas';
      v_tsquery      VARCHAR2(500);
   BEGIN
      cur := pac_md_listvalores.f_detvalores(828, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_tobject, 1000001, v_npasexec, v_tparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_ercarteraprimas;

   /*************************************************************************
   Recupera las base de calculo de la prima XL, devuelve un SYS_REFCURSOR
   param out : mensajes de error
   return : ref cursor
   *************************************************************************/
   FUNCTION f_get_basexl(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      v_npasexec     NUMBER(8) := 1;
      v_tparam       VARCHAR2(1) := NULL;
      v_tobject      VARCHAR2(200) := 'PAC_MD_LISTVALORES_REA.F_Get_basexl';
      v_v_terror     VARCHAR2(200) := 'Error recuperar base de calculo de la prima XL';
      v_tsquery      VARCHAR2(500);
   BEGIN
      cur := pac_md_listvalores.f_detvalores(341, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_tobject, 1000001, v_npasexec, v_tparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_basexl;

   /*************************************************************************
   Recupera el campo de aplicacion de la tasa, devuelve un SYS_REFCURSOR
   param out : mensajes de error
   return : ref cursor
   *************************************************************************/
   FUNCTION f_get_aplictasa(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      v_npasexec     NUMBER(8) := 1;
      v_tparam       VARCHAR2(1) := NULL;
      v_tobject      VARCHAR2(200) := 'PAC_MD_LISTVALORES_REA.F_Get_aplictasa';
      v_v_terror     VARCHAR2(200) := 'Error recuperar campo de aplicacion de la tasa';
      v_tsquery      VARCHAR2(500);
   BEGIN
      cur := pac_md_listvalores.f_detvalores(343, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_tobject, 1000001, v_npasexec, v_tparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_aplictasa;

   /*************************************************************************
   Recupera los tipos de tasa, devuelve un SYS_REFCURSOR
   param out : mensajes de error
   return : ref cursor
   *************************************************************************/
   FUNCTION f_get_tipotasa(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      v_npasexec     NUMBER(8) := 1;
      v_tparam       VARCHAR2(1) := NULL;
      v_tobject      VARCHAR2(200) := 'PAC_MD_LISTVALORES_REA.F_Get_tipotasa';
      v_v_terror     VARCHAR2(200) := 'Error recuperar tipos de tasa';
      v_tsquery      VARCHAR2(500);
   BEGIN
      cur := pac_md_listvalores.f_detvalores(344, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_tobject, 1000001, v_npasexec, v_tparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_tipotasa;

   /*************************************************************************
   Recupera los tipos de comision, devuelve un SYS_REFCURSOR
   param out : mensajes de error
   return : ref cursor
   *************************************************************************/
   FUNCTION f_get_tipocomision(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      v_npasexec     NUMBER(8) := 1;
      v_tparam       VARCHAR2(1) := NULL;
      v_tobject      VARCHAR2(200) := 'PAC_MD_LISTVALORES_REA.F_Get_tipocomision';
      v_v_terror     VARCHAR2(200) := 'Error recuperar tipos de comision';
      v_tsquery      VARCHAR2(500);
   BEGIN
      cur := pac_md_listvalores.f_detvalores(345, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_tobject, 1000001, v_npasexec, v_tparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_tipocomision;

   /*************************************************************************
   Recupera los tramos de comision, devuelve un SYS_REFCURSOR
   param out : mensajes de error
   return : ref cursor
   *************************************************************************/
   FUNCTION f_get_tramosrea(pctipo IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      v_npasexec     NUMBER(8) := 1;
      v_tparam       VARCHAR2(1) := NULL;
      v_tobject      VARCHAR2(200) := 'PAC_MD_LISTVALORES_REA.F_Get_tramosrea';
      v_v_terror     VARCHAR2(200) := 'Error recuperar tramos';
      v_tsquery      VARCHAR2(500);
   BEGIN
      -- 25822 KBR 03052013 Agregamos el valor y c¿¿digo del tramo en el caso que lo tenga definido
      v_tsquery :=
         'SELECT cr.ccodigo, cr.tdescripcion, rd.ctramo, rd.pctpart
            FROM cod_clausulas_reas ccr, clausulas_reas cr,
                 clausulas_reas_det rd
            WHERE ccr.ccodigo = rd.ccodigo (+)
              AND ccr.ccodigo = cr.ccodigo
              AND ccr.fvencim IS NULL
              AND ccr.ctipo = '
         || pctipo || ' AND cr.cidioma = ' || pac_md_common.f_get_cxtidioma()
         || ' ORDER BY cr.ccodigo';
      cur := pac_md_listvalores.f_opencursor(v_tsquery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_tobject, 1000001, v_npasexec, v_tparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_tramosrea;

   /*************************************************************************
   Recupera los contratos de proteccion, devuelve un SYS_REFCURSOR
   param in pcempres: codigo de la empresa
   param out : mensajes de error
   return : ref cursor
   *************************************************************************/
   FUNCTION f_get_contratoprot(pcempres IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      v_npasexec     NUMBER(8) := 1;
      v_tparam       VARCHAR2(1) := NULL;
      v_tobject      VARCHAR2(200) := 'PAC_MD_LISTVALORES_REA.F_Get_contratoprot';
      v_v_terror     VARCHAR2(200) := 'Error recuperar contratos de proteccion';
      v_tsquery      VARCHAR2(500);
   BEGIN
      -- ctiprea = 3.-XL ( Excess Loss) (detvalores = 106)
      v_tsquery :=
         'SELECT scontra, tdescripcion
            FROM codicontratos
           WHERE cempres = '
         || pcempres
         || ' AND ctiprea = 3
            AND (ffinctr IS NULL or finictr <> ffinctr)
           ORDER BY scontra';
      --AGG 27/06/2014 Si la fecha de inicio del contrato coincide con la fecha de fin el contrato no est¿¿¿ctivo
      cur := pac_md_listvalores.f_opencursor(v_tsquery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_tobject, 1000001, v_npasexec, v_tparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_contratoprot;

   /*************************************************************************
   Recupera las versiones (tabla CONTRATOS) de un contrato, devuelve un SYS_REFCURSOR
   param in pcempres: codigo de la empresa
   param in pscontra: codigo del contrato
   param out : mensajes de error
   return : ref cursor
   *************************************************************************/
   FUNCTION f_get_versionescontratoprot(
      pcempres IN NUMBER,
      pscontra IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      v_npasexec     NUMBER(8) := 1;
      v_tparam       VARCHAR2(1) := NULL;
      v_tobject      VARCHAR2(200) := 'PAC_MD_LISTVALORES_REA.F_Get_versionescontratoprot';
      v_v_terror     VARCHAR2(200) := 'Error recuperar versiones de un contrato';
      v_tsquery      VARCHAR2(500);
   BEGIN
      v_tsquery :=
         'SELECT c.nversio, c.tcontra
            FROM contratos c
           WHERE c.scontra = '
         || pscontra || ' ORDER BY c.nversio';
      cur := pac_md_listvalores.f_opencursor(v_tsquery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_tobject, 1000001, v_npasexec, v_tparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_versionescontratoprot;

   /*************************************************************************
   Recupera los tipos de prima XL, devuelve un SYS_REFCURSOR
   param out : mensajes de error
   return : ref cursor
   *************************************************************************/
   FUNCTION f_get_tipoprimaxl(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      v_npasexec     NUMBER(8) := 1;
      v_tparam       VARCHAR2(1) := NULL;
      v_tobject      VARCHAR2(200) := 'PAC_MD_LISTVALORES_REA.F_Get_tipoprimaxl';
      v_v_terror     VARCHAR2(200) := 'Error recuperar tipos de prima XL';
      v_tsquery      VARCHAR2(500);
   BEGIN
      cur := pac_md_listvalores.f_detvalores(342, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_tobject, 1000001, v_npasexec, v_tparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_tipoprimaxl;

   /*************************************************************************
   Recupera las reposiciones, devuelve un SYS_REFCURSOR
   param out : mensajes de error
   return : ref cursor
   *************************************************************************/
   FUNCTION f_get_reposiciones(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      v_npasexec     NUMBER(8) := 1;
      v_tparam       VARCHAR2(1) := NULL;
      v_tobject      VARCHAR2(200) := 'PAC_MD_LISTVALORES_REA.F_Get_reposiciones';
      v_v_terror     VARCHAR2(200) := 'Error recuperar reposiciones';
      v_tsquery      VARCHAR2(500);
   BEGIN
      v_tsquery :=
         'SELECT ccodigo, tdescripcion
            FROM reposiciones
           WHERE cidioma = '
         || pac_md_common.f_get_cxtidioma() || ' ORDER BY ccodigo';
      cur := pac_md_listvalores.f_opencursor(v_tsquery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_tobject, 1000001, v_npasexec, v_tparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_reposiciones;

   /*************************************************************************
   Recupera los tipos de clausulas / tramos escalonados, devuelve un SYS_REFCURSOR
   param out : mensajes de error
   return : ref cursor
   *************************************************************************/
   FUNCTION f_get_tipoclautramescal(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      v_npasexec     NUMBER(8) := 1;
      v_tparam       VARCHAR2(1) := NULL;
      v_tobject      VARCHAR2(200) := 'PAC_MD_LISTVALORES_REA.F_Get_tipoclautramescal';
      v_v_terror     VARCHAR2(200)
                                  := 'Error recuperar tipos de clausulas / tramos escalonados';
      v_tsquery      VARCHAR2(500);
   BEGIN
      cur := pac_md_listvalores.f_detvalores(346, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_tobject, 1000001, v_npasexec, v_tparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_tipoclautramescal;

   /*************************************************************************
   Recupera los contratos (tabla CODICONTRATOS), devuelve un SYS_REFCURSOR
   param out : mensajes de error
   return : ref cursor
   *************************************************************************/
   -- 14.0 - 22/09/2014 - MMM - 0027104: LCOLF3BREA- ID 180 FASE 3B - Cesiones Manuales - Inicio
   --FUNCTION f_get_contratos(pcempres IN NUMBER, mensajes IN OUT t_iax_mensajes)
   FUNCTION f_get_contratos(
      pcempres IN NUMBER,
      mensajes IN OUT t_iax_mensajes,
      pctipo IN NUMBER DEFAULT -1)
      -- 14.0 - 22/09/2014 - MMM - 0027104: LCOLF3BREA- ID 180 FASE 3B - Cesiones Manuales - Fin
   RETURN sys_refcursor IS
      cur            sys_refcursor;
      v_npasexec     NUMBER(8) := 1;
      v_tparam       VARCHAR2(200) := ' pcempres = ' || pcempres;
      v_tobject      VARCHAR2(200) := 'PAC_MD_LISTVALORES_REA.F_Get_contratos';
      v_v_terror     VARCHAR2(200) := 'Error recuperar contratos';
      v_tsquery      VARCHAR2(500);
   BEGIN
      v_tsquery :=
         'SELECT scontra, tdescripcion
            FROM codicontratos
           WHERE (ffinctr is null or finictr <> ffinctr) and cempres = '
         -- 14.0 - 22/09/2014 - MMM - 0027104: LCOLF3BREA- ID 180 FASE 3B - Cesiones Manuales
         -- Se aplica el filtro por CTIPREA si ¿¿¿e llega informado
         || pcempres || ' and DECODE(' || pctipo || ',-1, ctiprea, ' || pctipo
         || ') = ctiprea
         ORDER BY scontra';   -- NMM. 23830.11.02.2013.
      --AGG 27/06/2014 Si la fecha de inicio del contrato coincide con la fecha de fin el contrato no est¿¿¿ctivo
      cur := pac_md_listvalores.f_opencursor(v_tsquery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_tobject, 1000001, v_npasexec, v_tparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_contratos;

   /*************************************************************************
   Recupera las versiones (tabla CONTRATOS), devuelve un SYS_REFCURSOR
   param out : mensajes de error
   return : ref cursor
   *************************************************************************/
   FUNCTION f_get_versiones(pcempres IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      v_npasexec     NUMBER(8) := 1;
      v_tparam       VARCHAR2(200) := ' pcempres = ' || pcempres;
      v_tobject      VARCHAR2(200) := 'PAC_MD_LISTVALORES_REA.F_Get_versiones';
      v_v_terror     VARCHAR2(200) := 'Error recuperar versiones';
      v_tsquery      VARCHAR2(500);
   BEGIN
      v_tsquery :=
         'SELECT cc.scontra, cc.tdescripcion, c.nversio
            FROM codicontratos cc, contratos c
           WHERE cc.scontra = c.scontra
             AND (cc.ffinctr is null or cc.finictr <> cc.ffinctr) AND cc.cempres = '
         || pcempres || ' ORDER BY cc.scontra, c.nversio';
      --AGG 27/06/2014 Si la fecha de inicio coincide con la fecha de fin es que el contrato no est¿¿¿ctivo
      cur := pac_md_listvalores.f_opencursor(v_tsquery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_tobject, 1000001, v_npasexec, v_tparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_versiones;

   /*************************************************************************
   Recupera los brokers (tabla COMPANIAS), devuelve un SYS_REFCURSOR
   param out : mensajes de error
   return : ref cursor
   *************************************************************************/
   FUNCTION f_get_broker(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      v_npasexec     NUMBER(8) := 1;
      v_tparam       VARCHAR2(1) := NULL;
      v_tobject      VARCHAR2(200) := 'PAC_MD_LISTVALORES_REA.f_get_broker';
      v_v_terror     VARCHAR2(200) := 'Error recuperar los broker';
      v_tsquery      VARCHAR2(500);
   BEGIN
      -- Bug 23963/125448 - 17/10/2012 - AMC
      -- Bug 25502/137047 - 16/02/2013 - MLR
      v_tsquery :=
         'SELECT ccompani, tcompani
            FROM companias
            WHERE ctipcom = 2'
         -- 11.0 - 15/10/2013 - MMM - 0025502 - Nota 0155491 - LCOL_T020-Qtracker: 0005655: Validacion campos pantalla facultativos  - Inicio
         || ' AND (fbaja IS NULL OR fbaja > f_sysdate) ' ||
                                                            -- 11.0 - 15/10/2013 - MMM - 0025502 - Nota 0155491 - LCOL_T020-Qtracker: 0005655: Validacion campos pantalla facultativos  - Fin
         'ORDER BY ccompani';
      -- Fi Bug 23963/125448 - 17/10/2012 - AMC
      cur := pac_md_listvalores.f_opencursor(v_tsquery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_tobject, 1000001, v_npasexec, v_tparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_broker;

   /*************************************************************************
   Recupera todos los tipos de tramos (NO proporcionales y Proporcionales),
   devuelve un SYS_REFCURSOR param out : mensajes de error
   return : ref cursor
   *************************************************************************/
   FUNCTION f_get_tipostramos(pscontra IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vctiprea       NUMBER(1);
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_LISTVALORES_REA.F_Get_Tipostramos';
      terror         VARCHAR2(200) := 'Error recuperar tipos de tramos';
   BEGIN
      -- Nueva funcion: 0022076 23/05/2012 AVT
      SELECT ctiprea
        INTO vctiprea
        FROM codicontratos
       WHERE scontra = pscontra;

      IF vctiprea = 3 THEN
         cur := pac_md_listvalores_rea.f_get_tipostramos_noprop(mensajes);
      ELSE
         cur := pac_md_listvalores_rea.f_get_tipostramos_prop(vctiprea, mensajes);--BUG CONF-250  Fecha (02/09/2016) - HRE - se adiciona vctiprea
      END IF;

      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_tipostramos;

   /*************************************************************************
   Recupera todos los tipos de tramos (NO proporcionales y Proporcionales),
   devuelve un SYS_REFCURSOR param out : mensajes de error
   param in p_tparam : condicion de filtro
   return : ref cursor
   *************************************************************************/
   FUNCTION f_get_tipostramos_fil(p_tparam IN VARCHAR, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vctiprea       NUMBER(1);
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_LISTVALORES_REA.F_Get_Tipostramos';
      terror         VARCHAR2(200) := 'Error recuperar tipos de tramos';
   BEGIN
      cur := pac_md_listvalores_rea.f_get_tipostramos_prop_fil(p_tparam, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_tipostramos_fil;

   /*************************************************************************
   Recupera la lista de valores del desplegable para el estado de la cuenta
   devuelve un SYS_REFCURSOR param out : mensajes de error
   return : ref cursor

   VF: 800106 (0- Liquidada, 1- Pendiente, 2- Retenida)
   *************************************************************************/
   FUNCTION f_get_estado_cta(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_LISTVALORES_REA.F_Get_estado_cta';
      terror         VARCHAR2(200) := 'Error recuperar tipos de estado de la cuenta';
   BEGIN
      -- KBR 23830 - Ajustes en mtto de cta t¿¿cnica de reaseguro (QT:6163) 12/09/2013
      --Nueva funcion: 0022076 23/05/2012 AVT
      --cur := pac_md_listvalores.f_detvalores(800106, mensajes);
      cur := pac_md_listvalores.f_detvalorescond(800106, 'catribu not in (3)', mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_estado_cta;

/*************************************************************************
      Recupera la lista desplegable de conceptos de la cuenta tecnica del Reaseguro
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_tipo_movcta(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_LISTVALORES_REA.f_get_tipo_movcta ';
      terror         VARCHAR2(200) := 'Error recuperar tipos de movimientos de cuenta';
      vempresa       NUMBER;
   BEGIN
      --KBR 23830 19/09/2013
      vempresa := pac_md_common.f_get_cxtempresa;
      cur :=
         pac_md_listvalores.f_detvalorescond
                            (124,
                             'catribu in (select cconcep from tipoctarea where cempres = '
                             || vempresa || ' and (ctipcta = 1 or cconcep = 25))',
                             mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_tipo_movcta;

   /*************************************************************************
    Recupera los identificadores de pagos asociados a un siniestro
    param in pnsinies: n?mero del siniestro
    param out : mensajes de error
    return : ref cursor
    *************************************************************************/
   FUNCTION f_get_identif_pago_sin(pnsinies IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      v_npasexec     NUMBER(8) := 1;
      v_tparam       VARCHAR2(1) := NULL;
      v_tobject      VARCHAR2(200) := 'PAC_MD_LISTVALORES_REA.F_Get_identif_pago_sin';
      v_v_terror     VARCHAR2(200)
                               := 'Error al recuperar identificadores de pago de un siniestro';
      v_tsquery      VARCHAR2(500);
   BEGIN
      v_tsquery := 'SELECT sp.sidepag FROM sin_tramita_pago sp WHERE sp.nsinies = '
                   || pnsinies || ' ORDER BY sp.sidepag';
      cur := pac_md_listvalores.f_opencursor(v_tsquery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_tobject, 1000001, v_npasexec, v_tparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_identif_pago_sin;

    /*************************************************************************
      Recupera la versi¿¿¿¿igente de un contrato
      param in pcempres : empresa
      param in pscontra : contrato
      param out : mensajes de error
      return : ref cursor
   *************************************************************************/
   FUNCTION f_get_versionvigente_contrato(
      pcempres IN NUMBER,
      pscontra IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      v_npasexec     NUMBER(8) := 1;
      v_tparam       VARCHAR2(1) := NULL;
      v_tobject      VARCHAR2(200) := 'PAC_MD_LISTVALORES_REA.f_get_versionvigente_contrato';
      v_v_terror     VARCHAR2(200) := 'Error recuperar versi¿¿¿¿igente de un contrato';
      v_tsquery      VARCHAR2(500);
   BEGIN
      v_tsquery :=
         'SELECT c.nversio, c.tcontra
            FROM contratos c
           WHERE c.scontra = '
         || pscontra || ' AND fconfin IS NULL ORDER BY c.nversio';
      cur := pac_md_listvalores.f_opencursor(v_tsquery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_tobject, 1000001, v_npasexec, v_tparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_versionvigente_contrato;

   /*************************************************************************
      Recupera los ramos de un contrato
      param in pcempres : empresa
      param in pscontra : contrato
      param out : mensajes de error
      return : ref cursor
   *************************************************************************/
   FUNCTION f_get_ramos_contrato(
      pcempres IN NUMBER,
      pscontra IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      v_npasexec     NUMBER(8) := 1;
      v_tparam       VARCHAR2(1) := NULL;
      v_tobject      VARCHAR2(200) := 'PAC_MD_LISTVALORES_REA.f_get_ramos_contrato';
      v_v_terror     VARCHAR2(200) := 'Error recuperar ramos de un contrato';
      v_tsquery      VARCHAR2(500);
   BEGIN
      v_tsquery := 'select scontra, cramo from agr_contratos
         where scontra = ' || pscontra || ' order by cramo';
      cur := pac_md_listvalores.f_opencursor(v_tsquery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_tobject, 1000001, v_npasexec, v_tparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_ramos_contrato;
END pac_md_listvalores_rea;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_LISTVALORES_REA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_LISTVALORES_REA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_LISTVALORES_REA" TO "PROGRAMADORESCSI";
