--------------------------------------------------------
--  DDL for Package Body PAC_MD_MARCAS
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY PAC_MD_MARCAS AS
  /******************************************************************************
        NOMBRE:       PAC_MD_MARCAS
        PROPSITO:  Funciones para gestionar las marcas

        REVISIONES:
        Ver        Fecha        Autor   Descripcin
       ---------  ----------  ------   ------------------------------------
        1.0        01/08/2016   HRE     1. Creacin del package.
        2.0        19/02/2019   CJMR    2. TCS-344: Nuevo funcional Marcas
        3.0        19/06/2019   ECP     3. IAXIS-3981. Marcas Integrantes Consorcios y Uniones Temporales
        4.0        05/08/2019   JMJRR   4. IAXIS-4994. Se agrega filtro de marcas por configuración del usuario
  ******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;
  /*************************************************************************
    FUNCTION f_opencursor
      Abre un cursor con la sentencia suministrada
      param in squery    : consulta a executar
      param out mensajes : mesajes de error
      return             : ref cursor
  *************************************************************************/
   FUNCTION f_opencursor(squery IN VARCHAR2, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(4000) := SUBSTR(squery, 1, 1900);
      vobject        VARCHAR2(200) := 'pac_md_marcas.f_opencursor';
      terror         VARCHAR2(200) := 'No se puede recuperar la informacion';
   BEGIN
      OPEN cur FOR squery;
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           terror, SQLCODE, SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_opencursor;
  /*************************************************************************
    FUNCTION f_get_marcas
    Permite obtener la informacion de las marcas
    param in pcempres  : codigo de la empresa
    param out mensajes : mesajes de error
    return             : ref cursor
  *************************************************************************/
  FUNCTION f_get_marcas(pcempres IN NUMBER, mensajes IN OUT t_iax_mensajes)
    RETURN sys_refcursor IS
    cur      sys_refcursor;
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'pcempres=' || pcempres;
    vobject  VARCHAR2(200) := 'pac_iax_marcas.f_get_marcas';
    terror         VARCHAR2(200) := 'Error recuperar marcas';
  BEGIN
    cur := f_opencursor('SELECT am.cempres, am.cmarca, am.nmovimi, am.descripcion, am.caacion, am.carea,
                                am.slitera, am.ctomador, am.cconsorcio, am.casegurado, am.ccodeudor, am.cbenef,
                                am.caccionista, am.cintermed, am.crepresen, am.capoderado, am.cpagador, am.cproveedor'  -- CJMR TCS-344 19/02/2019
                     || '  FROM agr_marcas am'
                     || ' WHERE am.cempres = '|| pcempres
                     || ' ORDER BY am.descripcion ', mensajes);
    --
    RETURN cur;
  EXCEPTION
    WHEN OTHERS THEN
          pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

          IF cur%ISOPEN THEN
             CLOSE cur;
          END IF;

         RETURN cur;
  END f_get_marcas;

  /*************************************************************************
    FUNCTION f_get_marcas
    Permite obtener la informacion de las marcas asociadas a una persona
    param in pcempres  : codigo de la empresa
    param in psperson  : codigo de la persona
    param out mensajes : mesajes de error
    return             : ref cursor
  *************************************************************************/
  FUNCTION f_obtiene_marcas(pcempres IN NUMBER,
                            psperson IN NUMBER,
                            mensajes IN OUT t_iax_mensajes)
    RETURN t_iax_marcas IS
-- Ini IAXIS-3981 -- ECP --19/06/2019
    CURSOR cur_marcas IS
    SELECT c.catribu cod_area/*IAXIS-4994*/,c.tatribu area, a.cmarca, a.descripcion, DECODE(a.ctomador, 1, b.ctomador, -1) mtomador, DECODE(a.casegurado, 1,
                                 b.casegurado, -1) masegurado, DECODE(a.cintermed, 1, b.cintermed, -1) mintermediario,
                                 DECODE(a.cconsorcio, 1, b.cconsorcio, -1) mconsorcio, DECODE(a.ccodeudor, 1, b.ccodeudor, -1) mcodeudor,
                                 DECODE(a.cbenef, 1, b.cbenef, -1) mbenef, DECODE(a.caccionista, 1, b.caccionista, -1) maccionista, DECODE(a.crepresen, 1, b.crepresen, -1) mrepresen,
                                 DECODE(a.capoderado, 1, b.capoderado, -1) mapoderado, DECODE(a.cpagador, 1, b.cpagador, -1) mpagador, DECODE(a.cproveedor, 1, b.cproveedor, -1) mproveedor,  -- CJMR TCS-344 19/02/2019
                                 b.observacion, b.cuser, b.falta
                            FROM agr_marcas a, per_agr_marcas b, detvalores c
                           WHERE a.cempres = b.cempres
                             AND a.cmarca = b.cmarca
                             AND a.cempres = pcempres
                             AND b.sperson = psperson
                             AND a.carea = c.catribu
                             AND c.cvalor = 8002004
                             AND c.cidioma = pac_md_common.f_get_cxtidioma
                             AND b.nmovimi =  (SELECT MAX(nmovimi)
                                                 FROM per_agr_marcas e
                                                WHERE b.cempres = e.cempres
                                                  AND b.cmarca  = e.cmarca
                                                  AND b.sperson = e.sperson)
                          UNION
                          SELECT c.catribu cod_area/*IAXIS-4994*/,c.tatribu, a.cmarca, a.descripcion, DECODE(a.ctomador, 1, 0, -1) mtomador,
                                DECODE(a.casegurado, 1, 0, -1) masegurado, DECODE(a.cintermed, 1, 0, -1) mintermediario,
                                DECODE(a.cconsorcio, 1, 0, -1) mconsorcio, DECODE(a.ccodeudor, 1, 0, -1) mcodeudor,
                                DECODE(a.cbenef, 1, 0, -1) mbenef,
                                DECODE(a.caccionista, 1, 0, -1) maccionista, DECODE(a.crepresen, 1, 0, -1) mrepresen,
                                DECODE(a.capoderado, 1, 0, -1) mapoderado, DECODE(a.cpagador, 1, 0, -1) mpagador,
								DECODE(a.cproveedor, 1, 0, -1) mproveedor,  -- CJMR TCS-344 19/02/2019
                                null, a.cuser, a.falta
                            FROM agr_marcas a, detvalores c
                           WHERE a.carea = c.catribu
                             AND a.cempres = pcempres
                             AND c.cvalor = 8002004
                             AND c.cidioma = pac_md_common.f_get_cxtidioma
                             AND NOT EXISTS (SELECT 0 FROM per_agr_marcas e
                                              WHERE a.cempres = e.cempres
                                                AND a.cmarca = e.cmarca
                                                AND e.sperson = psperson
                                                AND e.nmovimi =  (SELECT MAX(nmovimi)
                                                                    FROM per_agr_marcas f
                                                                   WHERE f.cempres = e.cempres
                                                                     AND f.cmarca  = e.cmarca
                                                                     AND f.sperson = e.sperson)
                                                )
                          union
                          SELECT c.catribu cod_area/*IAXIS-4994*/,c.tatribu area, a.cmarca, a.descripcion, DECODE(a.ctomador, 1, b.ctomador, -1) mtomador, DECODE(a.casegurado, 1,
                                 b.casegurado, -1) masegurado, DECODE(a.cintermed, 1, b.cintermed, -1) mintermediario,
                                 DECODE(a.cconsorcio, 1, b.cconsorcio, -1) mconsorcio, DECODE(a.ccodeudor, 1, b.ccodeudor, -1) mcodeudor,
                                 DECODE(a.cbenef, 1, b.cbenef, -1) mbenef, DECODE(a.caccionista, 1, b.caccionista, -1) maccionista, DECODE(a.crepresen, 1, b.crepresen, -1) mrepresen,
                                 DECODE(a.capoderado, 1, b.capoderado, -1) mapoderado, DECODE(a.cpagador, 1, b.cpagador, -1) mpagador, DECODE(a.cproveedor, 1, b.cproveedor, -1) mproveedor,  -- CJMR TCS-344 19/02/2019
                                 b.observacion, b.cuser, b.falta
                            FROM agr_marcas a, per_agr_marcas b, detvalores c
                           WHERE a.cempres = b.cempres
                             AND a.cmarca = b.cmarca
                             AND a.cempres = pcempres
                             and f_consorcio(b.sperson) = 1
                                AND b.sperson in (select d.sperson from per_personas_rel d where d.sperson = psperson)
                             AND a.carea = c.catribu
                             AND c.cvalor = 8002004
                             AND c.cidioma = pac_md_common.f_get_cxtidioma
                             AND b.nmovimi =  (SELECT MAX(nmovimi)
                                                 FROM per_agr_marcas e
                                                WHERE b.cempres = e.cempres
                                                  AND b.cmarca  = e.cmarca
                                                  AND b.sperson = e.sperson)
                              union
                          SELECT c.catribu cod_area/*IAXIS-4994*/,c.tatribu area, a.cmarca, a.descripcion, DECODE(a.ctomador, 1, b.ctomador, -1) mtomador, DECODE(a.casegurado, 1,
                                 b.casegurado, -1) masegurado, DECODE(a.cintermed, 1, b.cintermed, -1) mintermediario,
                                 DECODE(a.cconsorcio, 1, b.cconsorcio, -1) mconsorcio, DECODE(a.ccodeudor, 1, b.ccodeudor, -1) mcodeudor,
                                 DECODE(a.cbenef, 1, b.cbenef, -1) mbenef, DECODE(a.caccionista, 1, b.caccionista, -1) maccionista, DECODE(a.crepresen, 1, b.crepresen, -1) mrepresen,
                                 DECODE(a.capoderado, 1, b.capoderado, -1) mapoderado, DECODE(a.cpagador, 1, b.cpagador, -1) mpagador, DECODE(a.cproveedor, 1, b.cproveedor, -1) mproveedor,  -- CJMR TCS-344 19/02/2019
                                 b.observacion, b.cuser, b.falta
                            FROM agr_marcas a, per_agr_marcas b, detvalores c
                           WHERE a.cempres = b.cempres
                             AND a.cmarca = b.cmarca
                             AND a.cempres = pcempres
                             and f_consorcio(b.sperson) = 0
                                AND b.sperson in (select d.sperson from per_personas_rel d where d.sperson_rel = psperson and d.cagrupa = (select max(e.cagrupa) from per_personas_rel e where e.sperson_rel = d.sperson_rel))
                             AND a.carea = c.catribu
                             AND c.cvalor = 8002004
                             AND c.cidioma = pac_md_common.f_get_cxtidioma
                             AND b.nmovimi =  (SELECT MAX(nmovimi)
                                                 FROM per_agr_marcas e
                                                WHERE b.cempres = e.cempres
                                                  AND b.cmarca  = e.cmarca
                                                  AND b.sperson = e.sperson)
                          /*UNION
                          SELECT c.tatribu, a.cmarca, a.descripcion, DECODE(a.ctomador, 1, 0, -1) mtomador,
                                DECODE(a.casegurado, 1, 0, -1) masegurado, DECODE(a.cintermed, 1, 0, -1) mintermediario,
                                DECODE(a.cconsorcio, 1, 0, -1) mconsorcio, DECODE(a.ccodeudor, 1, 0, -1) mcodeudor,
                                DECODE(a.cbenef, 1, 0, -1) mbenef,
                                DECODE(a.caccionista, 1, 0, -1) maccionista, DECODE(a.crepresen, 1, 0, -1) mrepresen,
                                DECODE(a.capoderado, 1, 0, -1) mapoderado, DECODE(a.cpagador, 1, 0, -1) mpagador,
                                DECODE(a.cproveedor, 1, 0, -1) mproveedor,  -- CJMR TCS-344 19/02/2019
                                null, a.cuser, a.falta
                            FROM agr_marcas a, detvalores c
                           WHERE a.carea = c.catribu
                             AND a.cempres = pcempres
                             AND c.cvalor = 8002004
                             AND c.cidioma = pac_md_common.f_get_cxtidioma
                             AND NOT EXISTS (SELECT 0 FROM per_agr_marcas e
                                              WHERE a.cempres = e.cempres
                                                AND a.cmarca = e.cmarca
                                                AND e.sperson = psperson
                                                AND e.nmovimi =  (SELECT MAX(nmovimi)
                                                                    FROM per_agr_marcas f
                                                                   WHERE f.cempres = e.cempres
                                                                     AND f.cmarca  = e.cmarca
                                                                     AND f.sperson = e.sperson)
                                                )*/
                          ORDER BY 1, 3;
-- Ini IAXIS-3981 -- ECP --19/06/2019
    t_marcas  t_iax_marcas;
    ob_marcas ob_iax_marcas;
    t_datos pac_util.t_array;/*IAXIS-4994*/
    user_areas VARCHAR2(50);/*IAXIS-4994*/
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'pcempres=' || pcempres||' psperson='||psperson;
    vobject  VARCHAR2(200) := 'pac_iax_marcas.f_get_marcas_per';
    terror         VARCHAR2(200) := 'Error recuperar marcas';
  BEGIN

   IF pcempres IS NULL OR psperson IS NULL THEN
         RAISE e_param_error;
   END IF;

   t_marcas := t_iax_marcas();
    /*ini IAXIS-4994*/
    SELECT CCFGMARCA
    into user_areas
    FROM CFG_USER WHERE CUSER = f_user();
    
    t_datos := pac_util.fu_split(user_areas, ',');
    /*fin IAXIS-4994*/
    FOR rg_marcas IN cur_marcas LOOP
        for i in 0..t_datos.count-1 loop /*IAXIS-4994*/
            IF rg_marcas.cod_area = t_datos(i) THEN/*IAXIS-4994*/
              t_marcas.EXTEND;
			  t_marcas(t_marcas.LAST) := ob_iax_marcas();--ob_marcas;
			  ob_marcas := ob_iax_marcas();
			  ob_marcas.cempres      := pcempres;
			  ob_marcas.sperson      := psperson;
			  ob_marcas.carea        := rg_marcas.area;
			  ob_marcas.cmarca       := rg_marcas.cmarca;
			  ob_marcas.descripcion  := rg_marcas.descripcion;
			  ob_marcas.ctomador     := rg_marcas.mtomador;
			  ob_marcas.cconsorcio   := rg_marcas.mconsorcio;
			  ob_marcas.casegurado   := rg_marcas.masegurado;
			  ob_marcas.ccodeudor    := rg_marcas.mcodeudor;
			  ob_marcas.cbenef       := rg_marcas.mbenef;
			  ob_marcas.caccionista  := rg_marcas.maccionista;
			  ob_marcas.cintermed    := rg_marcas.mintermediario;
			  ob_marcas.crepresen    := rg_marcas.mrepresen;
			  ob_marcas.capoderado   := rg_marcas.mapoderado;
			  ob_marcas.cpagador     := rg_marcas.mpagador;
			  -- INI CJMR TCS-344 19/02/2019
			  ob_marcas.cproveedor   := rg_marcas.mproveedor;
			  -- FIN CJMR TCS-344 19/02/2019
			  ob_marcas.observacion  := rg_marcas.observacion;
			  --ob_marcas.cvalor       := rg_marcas.cmarca;
			  ob_marcas.cuser        := rg_marcas.cuser;
			  ob_marcas.falta        := rg_marcas.falta;

			  t_marcas(t_marcas.LAST) := ob_marcas;
            END IF;/* IAXIS-4994*/
        END LOOP;/* IAXIS-4994*/
    END LOOP;
    RETURN t_marcas;

  EXCEPTION
    WHEN OTHERS THEN
          pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

   END f_obtiene_marcas;


  /*************************************************************************
    FUNCTION f_get_marcas_per
    Permite obtener la informacion de las marcas asociadas a una persona
    param in pcempres  : codigo de la empresa
    param in psperson  : codigo de la persona
    param out mensajes : mesajes de error
    return             : ref cursor
  *************************************************************************/
  FUNCTION f_get_marcas_per(pcempres IN NUMBER,
                            psperson IN NUMBER,
                            mensajes IN OUT t_iax_mensajes)
    RETURN sys_refcursor IS
    cur      sys_refcursor;
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'pcempres=' || pcempres||' psperson='||psperson;
    vobject  VARCHAR2(200) := 'pac_iax_marcas.f_get_marcas_per';
    terror         VARCHAR2(200) := 'Error recuperar marcas';
  BEGIN

     -- CJMR TCS-344 19/02/2019
     --IAXIS-3981 --ECP-- 19/06/2019 
     cur := f_opencursor('SELECT c.tatribu area, a.cmarca, a.descripcion, DECODE(b.ctipo,0, '||''''||'Manual'||''''||', '||
                                 ''''||'Automatica'||''''||') tipo, a.caacion, d.tatribu accion
                            FROM agr_marcas a, per_agr_marcas b, detvalores c, detvalores d
                           WHERE a.cempres = b.cempres
                             AND a.cmarca = b.cmarca
                             AND a.cempres = '||pcempres||'
                             AND b.sperson = '||psperson||'
                             AND a.carea = c.catribu
                             AND c.cvalor = 8002004
                             AND c.cidioma = '||pac_md_common.f_get_cxtidioma||'
                             AND a.caacion = d.catribu
                             AND d.cvalor = 8002008
                             AND d.cidioma = '||pac_md_common.f_get_cxtidioma||'
                             AND b.nmovimi =  (SELECT MAX(nmovimi)
                                                 FROM per_agr_marcas e
                                                WHERE b.cempres = e.cempres
                                                  AND b.cmarca  = e.cmarca
                                                  AND b.sperson = e.sperson)
                           union
                                                  SELECT c.tatribu area, a.cmarca, a.descripcion, DECODE(b.ctipo,0, '||''''||'Manual'||''''||', '||
                                 ''''||'Automatica'||''''||') tipo, a.caacion, d.tatribu accion
                            FROM agr_marcas a, per_agr_marcas b, detvalores c, detvalores d
                           WHERE a.cempres = b.cempres
                             AND a.cmarca = b.cmarca
                             AND a.cempres = '||pcempres||'
                             AND b.sperson in (select d.sperson_rel from per_personas_rel d where d.sperson = '||psperson||')
                             AND a.carea = c.catribu
                             AND c.cvalor = 8002004
                             AND c.cidioma = '||pac_md_common.f_get_cxtidioma||'
                             AND a.caacion = d.catribu
                             AND d.cvalor = 8002008
                             AND d.cidioma = '||pac_md_common.f_get_cxtidioma||'
                             AND b.nmovimi =  (SELECT MAX(nmovimi)
                                                 FROM per_agr_marcas e
                                                WHERE b.cempres = e.cempres
                                                  AND b.cmarca  = e.cmarca
                                                  AND b.sperson = e.sperson)', mensajes);
                                                  -- IAXIS -3981 --ECP -- 19/06/2019
    --

    RETURN cur;

  EXCEPTION
    WHEN OTHERS THEN
          pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

          IF cur%ISOPEN THEN
             CLOSE cur;
          END IF;

         RETURN cur;
  END f_get_marcas_per;

  /*************************************************************************
    FUNCTION f_get_marcas_perhistorico
    Permite obtener la informacion de todos los movimientos de una marca
    asociada a la persona
    param in pcempres  : codigo de la empresa
    param in psperson  : codigo de la persona
    param out mensajes : mesajes de error
    return             : ref cursor
  *************************************************************************/
  FUNCTION f_get_marcas_perhistorico(pcempres IN NUMBER,
                                     psperson IN NUMBER,
                                     pcmarca  IN VARCHAR2,
                                     mensajes IN OUT t_iax_mensajes)
    RETURN sys_refcursor IS
    cur      sys_refcursor;
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'pcempres=' || pcempres||' psperson='||psperson;
    vobject  VARCHAR2(200) := 'pac_iax_marcas.f_get_marcas_perhistorico';
  BEGIN

   -- CJMR TCS-344 19/02/2019
   cur := f_opencursor('SELECT c.tatribu area, a.cmarca, b.nmovimi, a.descripcion, DECODE(a.ctomador, 1, b.ctomador, -1) mtomador, DECODE(a.casegurado, 1,
                                 b.casegurado, -1) masegurado, DECODE(a.cintermed, 1, b.cintermed, -1) mintermediario,
                                 DECODE(a.cconsorcio, 1, b.cconsorcio, -1) mconsorcio, DECODE(a.ccodeudor, 1, b.ccodeudor, -1) mcodeudor,
                                 DECODE(a.cbenef, 1, b.cbenef, -1) mbenef, DECODE(a.caccionista, 1, b.caccionista, -1) maccionista, DECODE(a.crepresen, 1, b.crepresen, -1) mrepresen,
                                 DECODE(a.capoderado, 1, b.capoderado, -1) mapoderado, DECODE(a.cpagador, 1, b.cpagador, -1) mpagador, DECODE(a.cproveedor, 1, b.cproveedor, -1) mproveedor,
                                 b.cuser, to_char(b.falta, '||''''||'dd-mm-yyyy'||''''||')'||' falta, b.observacion
                            FROM agr_marcas a, per_agr_marcas b, detvalores c
                           WHERE a.cempres = b.cempres
                             AND a.cmarca = b.cmarca
                             AND a.cempres = '||pcempres||'
                             AND b.sperson = '||psperson||'
                             AND b.cmarca = '||pcmarca||'
                             AND a.carea = c.catribu
                             AND c.cvalor = 8002004
                             AND c.cidioma = 8
                             union
                             SELECT c.tatribu area, a.cmarca, b.nmovimi, a.descripcion, DECODE(a.ctomador, 1, b.ctomador, -1) mtomador, DECODE(a.casegurado, 1,
                                 b.casegurado, -1) masegurado, DECODE(a.cintermed, 1, b.cintermed, -1) mintermediario,
                                 DECODE(a.cconsorcio, 1, b.cconsorcio, -1) mconsorcio, DECODE(a.ccodeudor, 1, b.ccodeudor, -1) mcodeudor,
                                 DECODE(a.cbenef, 1, b.cbenef, -1) mbenef, DECODE(a.caccionista, 1, b.caccionista, -1) maccionista, DECODE(a.crepresen, 1, b.crepresen, -1) mrepresen,
                                 DECODE(a.capoderado, 1, b.capoderado, -1) mapoderado, DECODE(a.cpagador, 1, b.cpagador, -1) mpagador, DECODE(a.cproveedor, 1, b.cproveedor, -1) mproveedor,
                                 b.cuser, to_char(b.falta, '||''''||'dd-mm-yyyy'||''''||')'||' falta, b.observacion
                            FROM agr_marcas a, per_agr_marcas b, detvalores c
                           WHERE a.cempres = b.cempres
                             AND a.cmarca = b.cmarca
                             AND a.cempres = '||pcempres||'
                             AND b.sperson in (select d.sperson_rel from per_personas_rel d where d.sperson = '||psperson||')
                             AND b.cmarca = '||pcmarca||'
                             AND a.carea = c.catribu
                             AND c.cvalor = 8002004
                             AND c.cidioma = 8
                             order by nmovimi desc', mensajes);
    --
    RETURN cur;

  EXCEPTION
    WHEN OTHERS THEN
      pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                        vobject,
                                        1000001,
                                        vpasexec,
                                        vparam,
                                        psqcode  => SQLCODE,
                                        psqerrm  => SQLERRM);

      IF cur%ISOPEN THEN
        CLOSE cur;
      END IF;

      RETURN cur;

   END f_get_marcas_perhistorico;
   /*************************************************************************
    FUNCTION f_set_marcas_per
    Permite asociar marcas a la persona de forma manual
    param in pcempres  : codigo de la empresa
    param in psperson  : codigo de la persona
    param in pcmarca   : codigo de la marca
    param in pparam    : parametros de roles
    param out mensajes : mesajes de error
    return             : number
   *************************************************************************/
   FUNCTION f_set_marcas_per(pcempres IN NUMBER,
                            psperson IN NUMBER,
                            t_marcas   IN T_IAX_MARCAS,
                            mensajes IN OUT t_iax_mensajes)
   RETURN NUMBER IS
   vnumerr        NUMBER(8) := 0;
   vpasexec       NUMBER(8) := 1;
   vparam         VARCHAR2(500) := 'parmetros - pcempres: ' || pcempres || ' - psperson: ' || psperson;
   vobject        VARCHAR2(200) := 'pac_md_marcas.f_set_marcas_per';
   BEGIN

      vnumerr := pac_marcas.f_set_marcas_per(pcempres, psperson, t_marcas);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;

  END f_set_marcas_per;

/*************************************************************************
    FUNCTION f_set_marca_automatica
    Permite asociar   marcas a la persona en procesos del Sistema
    param in pcempres  : codigo de la empresa
    param in psperson  : codigo de la persona
    param in pcmarca   : codigo de la marca
    param in pparam    : parametros de roles
    param out mensajes : mesajes de error
    return             : number
  *************************************************************************/
  FUNCTION f_set_marca_automatica(pcempres IN NUMBER,
                                  psperson IN NUMBER,
                                  pcmarca  IN VARCHAR2,
                                  mensajes IN OUT t_iax_mensajes)
    RETURN NUMBER IS
     vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'parmetros - pcempres: ' || pcempres || ' - psperson: ' || psperson
            || ' - pcmarca: ' || pcmarca;
      vobject        VARCHAR2(200) := 'pac_md_marcas.f_set_marca_automatica';
   BEGIN

      vnumerr := pac_marcas.f_set_marca_automatica(pcempres, psperson, pcmarca);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;

  END f_set_marca_automatica;

/*************************************************************************
    FUNCTION f_del_marca_automatica
    Permite desactivar marcas a la persona
    param in pcempres  : codigo de la empresa
    param in psperson  : codigo de la persona
    param in pcmarca   : codigo de la marca
    param out mensajes : mesajes de error
    return             : number
  *************************************************************************/
  FUNCTION f_del_marca_automatica(pcempres IN NUMBER,
                                  psperson IN NUMBER,
                                  pcmarca  IN VARCHAR2,
                                  mensajes IN OUT t_iax_mensajes)
    RETURN NUMBER IS
        vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'parmetros - pcempres: ' || pcempres || ' - psperson: ' || psperson
            || ' - pcmarca: ' || pcmarca;
      vobject        VARCHAR2(200) := 'pac_md_marcas.f_del_marca_automatica';
   BEGIN

      vnumerr := pac_marcas.f_del_marca_automatica(pcempres, psperson, pcmarca);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
  END f_del_marca_automatica;
  --
    /*************************************************************************
    FUNCTION f_get_marcas_poliza
    Permite obtener la informacion de las marcas asociadas a una persona
    param in pcempres  : codigo de la empresa
    param in psseguro  : codigo del seguro
    param in ptablas  : EST o POL
    param out mensajes : mesajes de error
    return             : ref cursor
  *************************************************************************/
  FUNCTION f_get_marcas_poliza(pcempres IN NUMBER,
                               psseguro IN NUMBER,
                               ptablas  IN VARCHAR2,
                               mensajes IN OUT t_iax_mensajes)
    RETURN sys_refcursor IS
    cur      sys_refcursor;
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'pcempres=' || pcempres||' psseguro='||psseguro||' ptablas:'||ptablas;
    vobject  VARCHAR2(200) := 'pac_iax_marcas.f_get_marcas_per';
    terror         VARCHAR2(200) := 'Error recuperar marcas';
  BEGIN
-- INI - ML - 5013 - RETORNA MAS DE UNA FILA
        IF (ptablas = 'EST') THEN

        -- CJMR TCS-344 19/02/2019
        --IAXIS-3981 --ECP-- 19/06/2019 
        cur := f_opencursor('SELECT b.sperson,
       (SELECT c.tatribu
          FROM detvalores c
         WHERE c.catribu = a.carea
           AND c.cvalor = 8002004
           AND c.cidioma = 8) area,
       a.cmarca, a.descripcion,
       DECODE (b.ctipo, 0, ''Manual'', ''Automatica'') tipo, a.caacion,
       (SELECT d.tatribu
          FROM detvalores d
         WHERE d.catribu = a.caacion
           AND d.cvalor = 8002008
           AND d.cidioma = 8) accion,
          (SELECT j.tatribu || '' '' || h.nnumide
             FROM per_identificador h, detvalores j
            WHERE h.sperson = b.sperson
              AND h.ctipide = j.catribu
              AND j.cidioma = 8
              AND j.cvalor = 672)
       || '' ''
       || (SELECT i.tnombre || '' '' || i.tapelli1 || '' '' || i.tapelli2 persona
             FROM per_detper i
            WHERE i.sperson = b.sperson) persona,
       ''Tomador'' rol
  FROM agr_marcas a, per_agr_marcas b, estper_personas f, esttomadores g
 WHERE a.cempres = b.cempres
   AND a.cmarca = b.cmarca
   AND NVL (b.ctomador, 0) = 1
   AND b.sperson = f.spereal
   AND f.sperson = g.sperson
   AND f.sseguro = g.sseguro
   AND g.sseguro = '||psseguro||'
   AND a.cempres = '||pcempres||'
   AND b.nmovimi =
          (SELECT MAX (nmovimi)
             FROM per_agr_marcas e
            WHERE b.cempres = e.cempres
              AND b.cmarca = e.cmarca
              AND b.sperson = e.sperson)
UNION
SELECT b.sperson,
       (SELECT c.tatribu
          FROM detvalores c
         WHERE c.catribu = a.carea
           AND c.cvalor = 8002004
           AND c.cidioma = 8) area,
       a.cmarca, a.descripcion,
       DECODE (b.ctipo, 0, ''Manual'', ''Automatica'') tipo, a.caacion,
       (SELECT d.tatribu
          FROM detvalores d
         WHERE d.catribu = a.caacion
           AND d.cvalor = 8002008
           AND d.cidioma = 8) accion,
          (SELECT j.tatribu || '' '' || h.nnumide
             FROM estper_identificador h, detvalores j
            WHERE h.sperson = g.sperson
              AND h.ctipide = j.catribu
              AND j.cidioma = '||pac_md_common.f_get_cxtidioma||'
              AND j.cvalor = 672
             
              )
       || '' ''
       || (SELECT i.tnombre || '' '' || i.tapelli1 || '' '' || i.tapelli2 persona
             FROM estper_detper i
            WHERE i.sperson = g.sperson) persona,
       ''Asegurado'' rol
  FROM agr_marcas a, per_agr_marcas b, estper_personas f, estassegurats g
 WHERE a.cempres = b.cempres
   AND a.cmarca = b.cmarca
   AND NVL (b.casegurado, 0) = 1
   AND b.sperson = f.spereal
   AND f.sperson = g.sperson
   AND f.sseguro = g.sseguro
   AND g.sseguro = '||psseguro||'
   AND a.cempres = '||pcempres||'
   AND b.nmovimi =
          (SELECT MAX (nmovimi)
             FROM per_agr_marcas e
            WHERE b.cempres = e.cempres
              AND b.cmarca = e.cmarca
              AND b.sperson = e.sperson)
UNION
SELECT b.sperson,
       (SELECT c.tatribu
          FROM detvalores c
         WHERE c.catribu = a.carea
           AND c.cvalor = 8002004
           AND c.cidioma = 8) area,
       a.cmarca, a.descripcion,
       DECODE (b.ctipo, 0, ''Manual'', ''Automatica'') tipo, a.caacion,
       (SELECT d.tatribu
          FROM detvalores d
         WHERE d.catribu = a.caacion
           AND d.cvalor = 8002008
           AND d.cidioma = 8) accion,
          (SELECT j.tatribu || '' '' || h.nnumide
             FROM estper_identificador h, detvalores j
            WHERE h.sperson = g.sperson
              AND h.ctipide = j.catribu
              AND j.cidioma = '||pac_md_common.f_get_cxtidioma||'
              AND j.cvalor = 672)
       || '' ''
       || (SELECT i.tnombre || '' '' || i.tapelli1 || '' '' || i.tapelli2 persona
             FROM estper_detper i
            WHERE i.sperson = g.sperson) persona,
       ''Asegurado'' rol
  FROM agr_marcas a, per_agr_marcas b, estper_personas f, estassegurats g
 WHERE a.cempres = b.cempres
   AND a.cmarca = b.cmarca
   and f_consorcio(b.sperson) = 1
   AND NVL (a.casegurado, 0) = 1
   AND b.sperson = f.spereal
   AND f.sperson = g.sperson
   AND f.sseguro = g.sseguro
   AND g.sseguro = '||psseguro||'
   AND a.cempres = '||pcempres||'
   AND b.nmovimi =
          (SELECT MAX (nmovimi)
             FROM per_agr_marcas e
            WHERE b.cempres = e.cempres
              AND b.cmarca = e.cmarca
              AND b.sperson = e.sperson)
UNION
SELECT b.sperson,
       (SELECT c.tatribu
          FROM detvalores c
         WHERE c.catribu = a.carea
           AND c.cvalor = 8002004
           AND c.cidioma = 8) area,
       a.cmarca, a.descripcion,
       DECODE (b.ctipo, 0, ''Manual'', ''Automatica'') tipo, a.caacion,
       (SELECT d.tatribu
          FROM detvalores d
         WHERE d.catribu = a.caacion
           AND d.cvalor = 8002008
           AND d.cidioma = 8) accion,
          (SELECT j.tatribu || '' '' || h.nnumide
             FROM estper_identificador h, detvalores j
            WHERE h.sperson = g.sperson
              AND h.ctipide = j.catribu
              AND j.cidioma = '||pac_md_common.f_get_cxtidioma||'
              AND j.cvalor = 672)
       || '' ''
       || (SELECT i.tnombre || '' '' || i.tapelli1 || '' '' || i.tapelli2 persona
             FROM estper_detper i
            WHERE i.sperson = g.sperson) persona,
       ''Beneficiario'' rol
  FROM agr_marcas a, per_agr_marcas b, estper_personas f, estbenespseg g
 WHERE a.cempres = b.cempres
   AND a.cmarca = b.cmarca
   AND NVL (b.cbenef, 0) = 1
   AND b.sperson = f.spereal
   AND f.sperson = g.sperson
   AND f.sseguro = g.sseguro
   AND g.sseguro = '||psseguro||'
   AND a.cempres = '||pcempres||'
   AND b.nmovimi =
          (SELECT MAX (nmovimi)
             FROM per_agr_marcas e
            WHERE b.cempres = e.cempres
              AND b.cmarca = e.cmarca
              AND b.sperson = e.sperson)
UNION
SELECT b.sperson,
       (SELECT c.tatribu
          FROM detvalores c
         WHERE c.catribu = a.carea
           AND c.cvalor = 8002004
           AND c.cidioma = 8) area,
       a.cmarca, a.descripcion,
       DECODE (b.ctipo, 0, ''Manual'', ''Automatica'') tipo, a.caacion,
       (SELECT d.tatribu
          FROM detvalores d
         WHERE d.catribu = a.caacion
           AND d.cvalor = 8002008
           AND d.cidioma = 8) accion,
          (SELECT j.tatribu || '' '' || h.nnumide
             FROM per_identificador h, detvalores j
            WHERE h.sperson = b.sperson
              AND h.ctipide = j.catribu
              AND j.cidioma = '||pac_md_common.f_get_cxtidioma||'
              AND j.cvalor = 672)
       || '' ''
       || (SELECT i.tnombre || '' '' || i.tapelli1 || '' '' || i.tapelli2 persona
             FROM per_detper i
            WHERE i.sperson = b.sperson) persona,
       ''Intermediario'' rol
  FROM agr_marcas a, per_agr_marcas b, agentes a, estseguros s
 WHERE a.cempres = b.cempres
   AND a.cmarca = b.cmarca
   AND NVL (b.cintermed, 0) = 1
   AND b.sperson = a.sperson
   AND s.cagente = a.cagente
   AND s.sseguro = '||psseguro||'
   AND a.cempres = '||pcempres||'
   AND b.nmovimi =
          (SELECT MAX (nmovimi)
             FROM per_agr_marcas e
            WHERE b.cempres = e.cempres
              AND b.cmarca = e.cmarca
              AND b.sperson = e.sperson)
UNION
SELECT b.sperson,
       (SELECT c.tatribu
          FROM detvalores c
         WHERE c.catribu = a.carea
           AND c.cvalor = 8002004
           AND c.cidioma = 8) area,
       a.cmarca, a.descripcion,
       DECODE (b.ctipo, 0, ''Manual'', ''Automatica'') tipo, a.caacion,
       (SELECT d.tatribu
          FROM detvalores d
         WHERE d.catribu = a.caacion
           AND d.cvalor = 8002008
           AND d.cidioma = 8) accion,
          (SELECT j.tatribu || '' '' || h.nnumide
             FROM per_identificador h, detvalores j
            WHERE h.sperson = b.sperson
              AND h.ctipide = j.catribu
              AND j.cidioma = '||pac_md_common.f_get_cxtidioma||'
              AND j.cvalor = 672)
       || '' ''
       || (SELECT i.tnombre || '' '' || i.tapelli1 || '' '' || i.tapelli2 persona
             FROM per_detper i
            WHERE i.sperson = b.sperson) persona,
       ''Tomador'' rol
  FROM agr_marcas a,
       per_agr_marcas b,
       per_personas_rel pr,
       estper_personas m,
       esttomadores g
 WHERE a.cempres = b.cempres
   AND a.cmarca = b.cmarca
   AND NVL (b.ctomador, 0) = 1
   AND b.sperson = pr.sperson_rel
   AND pr.ctipper_rel = 0
   AND pr.sperson = m.spereal
   AND m.sperson = g.sperson
   AND g.sseguro = '||psseguro||'
   AND m.sseguro = '||psseguro||'
   AND pr.cagrupa = g.cagrupa
   AND a.cempres = '||pcempres||'
   AND b.nmovimi =
          (SELECT MAX (nmovimi)
             FROM per_agr_marcas e
            WHERE b.cempres = e.cempres
              AND b.cmarca = e.cmarca
              AND b.sperson = e.sperson)
UNION
SELECT b.sperson sperson,
       (SELECT c.tatribu
          FROM detvalores c
         WHERE c.catribu = a.carea
           AND c.cvalor = 8002004
           AND c.cidioma = 8) area,
       a.cmarca, a.descripcion,
       DECODE (b.ctipo, 0, ''Manual'', ''Automatica'') tipo, a.caacion,
       (SELECT d.tatribu
          FROM detvalores d
         WHERE d.catribu = a.caacion
           AND d.cvalor = 8002008
           AND d.cidioma = 8) accion,
          (SELECT j.tatribu || '' '' || h.nnumide
             FROM per_identificador h, detvalores j
            WHERE h.sperson IN
                     (SELECT f.spereal
                        FROM estper_personas f, estassegurats g
                       WHERE f.sperson = g.sperson
                         AND f.sseguro = g.sseguro
                         AND g.sseguro = '||psseguro||')
              AND h.ctipide = j.catribu
              AND j.cidioma = '||pac_md_common.f_get_cxtidioma||'
              AND j.cvalor = 672)
       || '' ''
       || (SELECT i.tnombre || '' '' || i.tapelli1 || '' '' || i.tapelli2 persona
             FROM per_detper i
            WHERE i.sperson =
                     (SELECT f.spereal
                        FROM estper_personas f, estassegurats g
                       WHERE f.sperson = g.sperson
                         AND f.sseguro = g.sseguro
                         AND g.sseguro = '||psseguro||')) persona,
       ''Asegurado'' rol
  FROM agr_marcas a,
       per_agr_marcas b,
       per_personas_rel pr,
       estper_personas m,
       estassegurats g
 WHERE a.cempres = b.cempres
   AND a.cmarca = b.cmarca
   AND NVL (a.casegurado, 0) = 1
   AND b.sperson = pr.sperson
   AND pr.ctipper_rel = 0
   AND pr.sperson_rel = m.spereal
   AND m.sperson = g.sperson
   AND g.sseguro = '||psseguro||'
   AND m.sseguro = '||psseguro||'
   AND a.cempres = '||pcempres||'
   AND b.nmovimi =
          (SELECT MAX (nmovimi)
             FROM per_agr_marcas e
            WHERE b.cempres = e.cempres
              AND b.cmarca = e.cmarca
              AND b.sperson = e.sperson)
UNION
SELECT b.sperson,
       (SELECT c.tatribu
          FROM detvalores c
         WHERE c.catribu = a.carea
           AND c.cvalor = 8002004
           AND c.cidioma = 8) area,
       a.cmarca, a.descripcion,
       DECODE (b.ctipo, 0, ''Manual'', ''Automatica'') tipo, a.caacion,
       (SELECT d.tatribu
          FROM detvalores d
         WHERE d.catribu = a.caacion
           AND d.cvalor = 8002008
           AND d.cidioma = 8) accion,
          (SELECT j.tatribu || '' '' || h.nnumide
             FROM per_identificador h, detvalores j
            WHERE h.sperson = b.sperson
              AND h.ctipide = j.catribu
              AND j.cidioma = '||pac_md_common.f_get_cxtidioma||'
              AND j.cvalor = 672)
       || '' ''
       || (SELECT i.tnombre || '' '' || i.tapelli1 || '' '' || i.tapelli2 persona
             FROM per_detper i
            WHERE i.sperson = b.sperson) persona,
       ''Beneficiario'' rol
  FROM agr_marcas a,
       per_agr_marcas b,
       per_personas_rel pr,
       estper_personas m,
       estbenespseg g
 WHERE a.cempres = b.cempres
   AND a.cmarca = b.cmarca
   AND NVL (b.cbenef, 0) = 1
   AND b.sperson = pr.sperson_rel
   AND pr.ctipper_rel = 0
   AND pr.sperson = m.spereal
   AND m.sperson = g.sperson
   AND g.sseguro = '||psseguro||'
   AND m.sseguro = '||psseguro||'
   AND a.cempres = '||pcempres||'
   AND b.nmovimi =
          (SELECT MAX (nmovimi)
             FROM per_agr_marcas e
            WHERE b.cempres = e.cempres
              AND b.cmarca = e.cmarca
              AND b.sperson = e.sperson)
UNION
SELECT b.sperson,
       (SELECT c.tatribu
          FROM detvalores c
         WHERE c.catribu = a.carea
           AND c.cvalor = 8002004
           AND c.cidioma = 8) area,
       a.cmarca, a.descripcion,
       DECODE (b.ctipo, 0, ''Manual'', ''Automatica'') tipo, a.caacion,
       (SELECT d.tatribu
          FROM detvalores d
         WHERE d.catribu = a.caacion
           AND d.cvalor = 8002008
           AND d.cidioma = 8) accion,
          (SELECT j.tatribu || '' '' || h.nnumide
             FROM per_identificador h, detvalores j
            WHERE h.sperson = pr.sperson_rel
              AND h.ctipide = j.catribu
              AND j.cidioma = '||pac_md_common.f_get_cxtidioma||'
              AND j.cvalor = 672)
       || '' ''
       || i.tnombre
       || '' ''
       || i.tapelli1
       || '' ''
       || i.tapelli2 persona,
       ''Tomador'' rol
  FROM agr_marcas a,
       per_agr_marcas b,
       per_personas_rel pr,
       per_detper i,
       estper_personas m,
       esttomadores g,
       per_personas_rel pr1,
       estper_personas n,
       esttomadores g1
 WHERE a.cempres = b.cempres
   AND a.cmarca = b.cmarca
   AND NVL (b.ctomador, 0) = 1
   AND pr.sperson_rel = i.sperson
   AND pr.ctipper_rel = 0
   AND pr.sperson = m.spereal
   AND m.sperson = g.sperson
   AND g.sseguro = '||psseguro||'
   AND m.sseguro = '||psseguro||'
   AND b.sperson = pr1.sperson
   AND pr1.ctipper_rel = 0
   AND pr1.sperson = n.spereal
   AND n.sperson = g1.sperson
   AND g1.sseguro = '||psseguro||'
   AND n.sseguro = '||psseguro||'
   AND a.cempres = '||pcempres||'
   AND b.nmovimi =
          (SELECT MAX (nmovimi)
             FROM per_agr_marcas e
            WHERE b.cempres = e.cempres
              AND b.cmarca = e.cmarca
              AND b.sperson = e.sperson)
UNION
SELECT b.sperson,
       (SELECT c.tatribu
          FROM detvalores c
         WHERE c.catribu = a.carea
           AND c.cvalor = 8002004
           AND c.cidioma = 8) area,
       a.cmarca, a.descripcion,
       DECODE (b.ctipo, 0, ''Manual'', ''Automatica'') tipo, a.caacion,
       (SELECT d.tatribu
          FROM detvalores d
         WHERE d.catribu = a.caacion
           AND d.cvalor = 8002008
           AND d.cidioma = 8) accion,
          (SELECT j.tatribu || '' '' || h.nnumide
             FROM per_identificador h, detvalores j
            WHERE h.sperson = pr.sperson_rel
              AND h.ctipide = j.catribu
              AND j.cidioma = '||pac_md_common.f_get_cxtidioma||'
              AND j.cvalor = 672)
       || '' ''
       || i.tnombre
       || '' ''
       || i.tapelli1
       || '' ''
       || i.tapelli2 persona,
       ''Asegurado'' rol
  FROM agr_marcas a,
       per_agr_marcas b,
       per_personas_rel pr,
       per_detper i,
       per_personas_rel pr1,
       estper_personas f,
       estassegurats g,
       estper_personas f1,
       estassegurats g1
 WHERE a.cempres = b.cempres
   AND a.cmarca = b.cmarca
   AND b.sperson = pr1.sperson
   AND pr1.ctipper_rel = 0
   AND pr1.sperson = f.spereal
   AND f.sperson = g.sperson
   AND f.sseguro = g.sseguro
   AND g.sseguro = '||psseguro||'
    and f_consorcio(b.sperson) = 1
   AND pr.sperson_rel = i.sperson
   AND NVL (pr.cagrupa, 1) = 1
   AND pr.ctipper_rel = 0
   AND NVL (a.casegurado, 0) = 1
   AND pr.sperson = f1.spereal
   AND f1.sperson = g1.sperson
   AND f1.sseguro = g1.sseguro
   AND g1.sseguro = '||psseguro||'
   AND a.cempres = '||pcempres||'
   AND b.nmovimi =
          (SELECT MAX (nmovimi)
             FROM per_agr_marcas e
            WHERE b.cempres = e.cempres
              AND b.cmarca = e.cmarca
              AND b.sperson = e.sperson)', mensajes);

       ELSIF (ptablas = 'POL') THEN
        -- CJMR TCS-344 19/02/2019
        cur := f_opencursor('SELECT b.sperson, c.tatribu area, a.cmarca, a.descripcion, DECODE(b.ctipo,0, '||''''||'Manual'||''''||','||''''||'Automatica'||''''||
                ') tipo, a.caacion, d.tatribu accion, j.tatribu||'||''''||' '||''''||'||h.nnumide||'||''''||' '||''''||'||i.tnombre||'||''''||
                ' '||''''||'||i.tapelli1||'||''''||' '||''''||'||i.tapelli2 persona, '||''''||'Tomador'||''''||' rol
        FROM agr_marcas a, per_agr_marcas b, detvalores c, detvalores d, per_personas h, per_detper i, detvalores j
       WHERE a.cempres = b.cempres
         AND a.cmarca = b.cmarca
         AND b.sperson = h.sperson
         AND h.sperson = i.sperson
         AND h.ctipide = j.catribu
         AND j.cidioma = '||pac_md_common.f_get_cxtidioma||'
         AND j.cvalor = 672
         AND NVL(b.ctomador, 0) = 1
         AND b.sperson IN (SELECT f.sperson
                             FROM per_personas f, tomadores g
                            WHERE f.sperson = g.sperson
                              AND g.sseguro = '||psseguro||'
                           )
         AND a.cempres = '||pcempres||'
         AND a.carea = c.catribu
         AND c.cvalor = 8002004
         AND c.cidioma = '||pac_md_common.f_get_cxtidioma||'
         AND a.caacion = d.catribu
         AND d.cvalor = 8002008
         AND d.cidioma = '||pac_md_common.f_get_cxtidioma||'
         AND b.nmovimi =  (SELECT MAX(nmovimi)
                             FROM per_agr_marcas e
                            WHERE b.cempres = e.cempres
                              AND b.cmarca  = e.cmarca
                              AND b.sperson = e.sperson)
    UNION
    SELECT b.sperson, c.tatribu area, a.cmarca, a.descripcion, DECODE(b.ctipo,0, '||''''||'Manual'||''''||','||''''||'Automatica'||''''||
                ') tipo, a.caacion, d.tatribu accion, j.tatribu||'||''''||' '||''''||'||h.nnumide||'||''''||' '||''''||'||i.tnombre||'||''''||
                ' '||''''||'||i.tapelli1||'||''''||' '||''''||'||i.tapelli2 persona, '||''''||'Asegurado'||''''||' rol
        FROM agr_marcas a, per_agr_marcas b, detvalores c, detvalores d, per_personas h, per_detper i, detvalores j
       WHERE a.cempres = b.cempres
         AND a.cmarca = b.cmarca
         AND b.sperson = h.sperson
         AND h.sperson = i.sperson
         AND h.ctipide = j.catribu
         AND j.cidioma = '||pac_md_common.f_get_cxtidioma||'
         AND j.cvalor = 672
         AND NVL(b.casegurado, 0) = 1
         AND b.sperson IN (SELECT f.sperson
                             FROM per_personas f, asegurados g
                            WHERE f.sperson = g.sperson
                              AND g.sseguro = '||psseguro||'
                           )
         AND a.cempres = '||pcempres||'
         AND a.carea = c.catribu
         AND c.cvalor = 8002004
         AND c.cidioma = '||pac_md_common.f_get_cxtidioma||'
         AND a.caacion = d.catribu
         AND d.cvalor = 8002008
         AND d.cidioma = '||pac_md_common.f_get_cxtidioma||'
         AND b.nmovimi =  (SELECT MAX(nmovimi)
                             FROM per_agr_marcas e
                            WHERE b.cempres = e.cempres
                              AND b.cmarca  = e.cmarca
                              AND b.sperson = e.sperson)

    UNION
    SELECT b.sperson, c.tatribu area, a.cmarca, a.descripcion, DECODE(b.ctipo,0, '||''''||'Manual'||''''||','||''''||'Automatica'||''''||
                ') tipo, a.caacion, d.tatribu accion, j.tatribu||'||''''||' '||''''||'||h.nnumide||'||''''||' '||''''||'||i.tnombre||'||''''||
                ' '||''''||'||i.tapelli1||'||''''||' '||''''||'||i.tapelli2 persona, '||''''||'Beneficiario'||''''||' rol
        FROM agr_marcas a, per_agr_marcas b, detvalores c, detvalores d, per_personas h, per_detper i, detvalores j
       WHERE a.cempres = b.cempres
         AND a.cmarca = b.cmarca
         AND b.sperson = h.sperson
         AND h.sperson = i.sperson
         AND h.ctipide = j.catribu
         AND j.cidioma = '||pac_md_common.f_get_cxtidioma||'
         AND j.cvalor = 672
         AND NVL(b.cbenef, 0) = 1
         AND b.sperson IN (SELECT f.sperson
                             FROM per_personas f, benespseg g
                            WHERE f.sperson = g.sperson
                              AND g.sseguro = '||psseguro||'
                           )
         AND a.cempres = '||pcempres||'
         AND a.carea = c.catribu
         AND c.cvalor = 8002004
         AND c.cidioma = '||pac_md_common.f_get_cxtidioma||'
         AND a.caacion = d.catribu
         AND d.cvalor = 8002008
         AND d.cidioma = '||pac_md_common.f_get_cxtidioma||'
         AND b.nmovimi =  (SELECT MAX(nmovimi)
                             FROM per_agr_marcas e
                            WHERE b.cempres = e.cempres
                              AND b.cmarca  = e.cmarca
                              AND b.sperson = e.sperson)
    UNION
    SELECT b.sperson, c.tatribu area, a.cmarca, a.descripcion, DECODE(b.ctipo,0, '||''''||'Manual'||''''||','||''''||'Automatica'||''''||
                ') tipo, a.caacion, d.tatribu accion, j.tatribu||'||''''||' '||''''||'||h.nnumide||'||''''||' '||''''||'||i.tnombre||'||''''||
                ' '||''''||'||i.tapelli1||'||''''||' '||''''||'||i.tapelli2 persona, '||''''||'Intermediario'||''''||' rol
        FROM agr_marcas a, per_agr_marcas b, detvalores c, detvalores d, per_personas h, per_detper i, detvalores j
       WHERE a.cempres = b.cempres
         AND a.cmarca = b.cmarca
         AND b.sperson = h.sperson
         AND h.sperson = i.sperson
         AND h.ctipide = j.catribu
         AND j.cidioma = '||pac_md_common.f_get_cxtidioma||'
         AND j.cvalor = 672
         AND NVL(b.cintermed, 0) = 1
         AND b.sperson IN (select a.sperson
                             from agentes a, seguros s
                            where s.cagente = a.cagente
                              and s.sseguro =  '||psseguro||'
                           )
         AND a.cempres = '||pcempres||'
         AND a.carea = c.catribu
         AND c.cvalor = 8002004
         AND c.cidioma = '||pac_md_common.f_get_cxtidioma||'
         AND a.caacion = d.catribu
         AND d.cvalor = 8002008
         AND d.cidioma = '||pac_md_common.f_get_cxtidioma||'
         AND b.nmovimi =  (SELECT MAX(nmovimi)
                             FROM per_agr_marcas e
                            WHERE b.cempres = e.cempres
                              AND b.cmarca  = e.cmarca
                              AND b.sperson = e.sperson)
 union
 SELECT b.sperson, c.tatribu area, a.cmarca, a.descripcion, DECODE(b.ctipo,0, '||''''||'Manual'||''''||','||''''||'Automatica'||''''||
                ') tipo, a.caacion, d.tatribu accion, j.tatribu||'||''''||' '||''''||'||h.nnumide||'||''''||' '||''''||'||i.tnombre||'||''''||
                ' '||''''||'||i.tapelli1||'||''''||' '||''''||'||i.tapelli2 persona, '||''''||'Tomador'||''''||' rol
        FROM agr_marcas a, per_agr_marcas b, detvalores c, detvalores d, per_personas h, per_detper i, detvalores j
       WHERE a.cempres = b.cempres
         AND a.cmarca = b.cmarca
         AND b.sperson = h.sperson
         AND h.sperson = i.sperson
         AND h.ctipide = j.catribu
         AND j.cidioma = '||pac_md_common.f_get_cxtidioma||'
         AND j.cvalor = 672
         AND NVL(b.ctomador, 0) = 1
         AND b.sperson IN (select sperson_rel from per_personas_rel where ctipper_rel = 0 and sperson = (SELECT g.sperson
                             FROM tomadores g
                            WHERE g.sseguro = '||psseguro||'
                           ))
         AND a.cempres = '||pcempres||'
         AND a.carea = c.catribu
         AND c.cvalor = 8002004
         AND c.cidioma = '||pac_md_common.f_get_cxtidioma||'
         AND a.caacion = d.catribu
         AND d.cvalor = 8002008
         AND d.cidioma = '||pac_md_common.f_get_cxtidioma||'
         AND b.nmovimi =  (SELECT MAX(nmovimi)
                             FROM per_agr_marcas e
                            WHERE b.cempres = e.cempres
                              AND b.cmarca  = e.cmarca
                              AND b.sperson = e.sperson)
    UNION
    SELECT b.sperson, c.tatribu area, a.cmarca, a.descripcion, DECODE(b.ctipo,0, '||''''||'Manual'||''''||','||''''||'Automatica'||''''||
                ') tipo, a.caacion, d.tatribu accion, j.tatribu||'||''''||' '||''''||'||h.nnumide||'||''''||' '||''''||'||i.tnombre||'||''''||
                ' '||''''||'||i.tapelli1||'||''''||' '||''''||'||i.tapelli2 persona, '||''''||'Asegurado'||''''||' rol
        FROM agr_marcas a, per_agr_marcas b, detvalores c, detvalores d, per_personas h, per_detper i, detvalores j
       WHERE a.cempres = b.cempres
         AND a.cmarca = b.cmarca
         AND b.sperson = h.sperson
         AND h.sperson = i.sperson
         AND h.ctipide = j.catribu
         AND j.cidioma = '||pac_md_common.f_get_cxtidioma||'
         AND j.cvalor = 672
         AND NVL(b.casegurado, 0) = 1
         AND b.sperson IN (select sperson_rel from per_personas_rel where ctipper_rel = 0 and sperson IN (SELECT g.sperson
                             FROM asegurados g
                            WHERE g.sseguro = '||psseguro||'
                           ))
         AND a.cempres = '||pcempres||'
         AND a.carea = c.catribu
         AND c.cvalor = 8002004
         AND c.cidioma = '||pac_md_common.f_get_cxtidioma||'
         AND a.caacion = d.catribu
         AND d.cvalor = 8002008
         AND d.cidioma = '||pac_md_common.f_get_cxtidioma||'
         AND b.nmovimi =  (SELECT MAX(nmovimi)
                             FROM per_agr_marcas e
                            WHERE b.cempres = e.cempres
                              AND b.cmarca  = e.cmarca
                              AND b.sperson = e.sperson)

    UNION
    SELECT b.sperson, c.tatribu area, a.cmarca, a.descripcion, DECODE(b.ctipo,0, '||''''||'Manual'||''''||','||''''||'Automatica'||''''||
                ') tipo, a.caacion, d.tatribu accion, j.tatribu||'||''''||' '||''''||'||h.nnumide||'||''''||' '||''''||'||i.tnombre||'||''''||
                ' '||''''||'||i.tapelli1||'||''''||' '||''''||'||i.tapelli2 persona, '||''''||'Beneficiario'||''''||' rol
        FROM agr_marcas a, per_agr_marcas b, detvalores c, detvalores d, per_personas h, per_detper i, detvalores j
       WHERE a.cempres = b.cempres
         AND a.cmarca = b.cmarca
         AND b.sperson = h.sperson
         AND h.sperson = i.sperson
         AND h.ctipide = j.catribu
         AND j.cidioma = '||pac_md_common.f_get_cxtidioma||'
         AND j.cvalor = 672
         AND NVL(b.cbenef, 0) = 1
          AND b.sperson IN (select sperson_rel from per_personas_rel where ctipper_rel = 0 and sperson IN (SELECT g.sperson
                             FROM benespseg g
                            WHERE g.sseguro = '||psseguro||'
                           ))
         AND a.cempres = '||pcempres||'
         AND a.carea = c.catribu
         AND c.cvalor = 8002004
         AND c.cidioma = '||pac_md_common.f_get_cxtidioma||'
         AND a.caacion = d.catribu
         AND d.cvalor = 8002008
         AND d.cidioma = '||pac_md_common.f_get_cxtidioma||'
         AND b.nmovimi =  (SELECT MAX(nmovimi)
                             FROM per_agr_marcas e
                            WHERE b.cempres = e.cempres
                              AND b.cmarca  = e.cmarca
                              AND b.sperson = e.sperson)', mensajes);


       END IF;
       --IAXIS-3981 --ECP-- 19/06/2019 
    --
-- FIN - ML - 5013 - RETORNA MAS DE UNA FILA
    RETURN cur;

  EXCEPTION
    WHEN OTHERS THEN
          pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

          IF cur%ISOPEN THEN
             CLOSE cur;
          END IF;

         RETURN cur;
  END f_get_marcas_poliza;

  /*************************************************************************
    FUNCTION f_get_accion_poliza
    Permite obtener la maxima accion de las marcas asociadas a tomadores,
    asegurados o beneficiarios de una poliza
    param in pcempres  : codigo de la empresa
    param in psseguro  : codigo del seguro
    param in ptablas  : EST o POL
    param out mensajes : mesajes de error
    return             : number
  *************************************************************************/
  FUNCTION f_get_accion_poliza(pcempres IN NUMBER,
                               psseguro IN NUMBER,
                               ptablas  IN VARCHAR2,
                               mensajes IN OUT t_iax_mensajes)
  RETURN NUMBER IS

  CURSOR cur_accion IS
     SELECT NVL(MAX(caacion),-1) accion
       FROM (
SELECT a.caacion
  FROM agr_marcas a, per_agr_marcas b, estper_personas f, esttomadores g
 WHERE a.cempres = b.cempres
   AND a.cmarca = b.cmarca
   AND NVL (b.ctomador, 0) = 1
   AND b.sperson = f.spereal
   AND f.sperson = g.sperson
   AND f.sseguro = g.sseguro
   AND g.sseguro = psseguro
   AND a.cempres = pcempres
   AND b.nmovimi =
          (SELECT MAX (nmovimi)
             FROM per_agr_marcas e
            WHERE b.cempres = e.cempres
              AND b.cmarca = e.cmarca
              AND b.sperson = e.sperson)
UNION
SELECT a.caacion
  FROM agr_marcas a, per_agr_marcas b, estper_personas f, estassegurats g
 WHERE a.cempres = b.cempres
   AND a.cmarca = b.cmarca
   AND NVL (b.casegurado, 0) = 1
   AND b.sperson = f.spereal
   AND f.sperson = g.sperson
   AND f.sseguro = g.sseguro
   AND g.sseguro = psseguro
   AND a.cempres = pcempres
   AND b.nmovimi =
          (SELECT MAX (nmovimi)
             FROM per_agr_marcas e
            WHERE b.cempres = e.cempres
              AND b.cmarca = e.cmarca
              AND b.sperson = e.sperson)
UNION
SELECT a.caacion
  FROM agr_marcas a, per_agr_marcas b, estper_personas f, estassegurats g
 WHERE a.cempres = b.cempres
   AND a.cmarca = b.cmarca
   and f_consorcio(b.sperson) = 1
   AND NVL (a.casegurado, 0) = 1
   AND b.sperson = f.spereal
   AND f.sperson = g.sperson
   AND f.sseguro = g.sseguro
   AND g.sseguro = psseguro
   AND a.cempres = pcempres
   AND b.nmovimi =
          (SELECT MAX (nmovimi)
             FROM per_agr_marcas e
            WHERE b.cempres = e.cempres
              AND b.cmarca = e.cmarca
              AND b.sperson = e.sperson)
UNION
SELECT a.caacion
  FROM agr_marcas a, per_agr_marcas b, estper_personas f, estbenespseg g
 WHERE a.cempres = b.cempres
   AND a.cmarca = b.cmarca
   AND NVL (b.cbenef, 0) = 1
   AND b.sperson = f.spereal
   AND f.sperson = g.sperson
   AND f.sseguro = g.sseguro
   AND g.sseguro = psseguro
   AND a.cempres = pcempres
   AND b.nmovimi =
          (SELECT MAX (nmovimi)
             FROM per_agr_marcas e
            WHERE b.cempres = e.cempres
              AND b.cmarca = e.cmarca
              AND b.sperson = e.sperson)
UNION
SELECT a.caacion
  FROM agr_marcas a, per_agr_marcas b, agentes a, estseguros s
 WHERE a.cempres = b.cempres
   AND a.cmarca = b.cmarca
   AND NVL (b.cintermed, 0) = 1
   AND b.sperson = a.sperson
   AND s.cagente = a.cagente
   AND s.sseguro = psseguro
   AND a.cempres = pcempres
   AND b.nmovimi =
          (SELECT MAX (nmovimi)
             FROM per_agr_marcas e
            WHERE b.cempres = e.cempres
              AND b.cmarca = e.cmarca
              AND b.sperson = e.sperson)
UNION
SELECT a.caacion
  FROM agr_marcas a,
       per_agr_marcas b,
       per_personas_rel pr,
       estper_personas m,
       esttomadores g
 WHERE a.cempres = b.cempres
   AND a.cmarca = b.cmarca
   AND NVL (b.ctomador, 0) = 1
   AND b.sperson = pr.sperson_rel
   AND pr.ctipper_rel = 0
   AND pr.sperson = m.spereal
   AND m.sperson = g.sperson
   AND g.sseguro = psseguro
   AND m.sseguro = psseguro
   AND pr.cagrupa = g.cagrupa
   AND a.cempres = pcempres
   AND b.nmovimi =
          (SELECT MAX (nmovimi)
             FROM per_agr_marcas e
            WHERE b.cempres = e.cempres
              AND b.cmarca = e.cmarca
              AND b.sperson = e.sperson)
UNION
SELECT a.caacion
  FROM agr_marcas a,
       per_agr_marcas b,
       per_personas_rel pr,
       estper_personas m,
       estassegurats g
 WHERE a.cempres = b.cempres
   AND a.cmarca = b.cmarca
   AND NVL (a.casegurado, 0) = 1
   AND b.sperson = pr.sperson
   AND pr.ctipper_rel = 0
   AND pr.sperson_rel = m.spereal
   AND m.sperson = g.sperson
   AND g.sseguro = psseguro
   AND m.sseguro = psseguro
   AND a.cempres = pcempres
   AND b.nmovimi =
          (SELECT MAX (nmovimi)
             FROM per_agr_marcas e
            WHERE b.cempres = e.cempres
              AND b.cmarca = e.cmarca
              AND b.sperson = e.sperson)
UNION
SELECT a.caacion
  FROM agr_marcas a,
       per_agr_marcas b,
       per_personas_rel pr,
       estper_personas m,
       estbenespseg g
 WHERE a.cempres = b.cempres
   AND a.cmarca = b.cmarca
   AND NVL (b.cbenef, 0) = 1
   AND b.sperson = pr.sperson_rel
   AND pr.ctipper_rel = 0
   AND pr.sperson = m.spereal
   AND m.sperson = g.sperson
   AND g.sseguro = psseguro
   AND m.sseguro = psseguro
   AND a.cempres = pcempres
   AND b.nmovimi =
          (SELECT MAX (nmovimi)
             FROM per_agr_marcas e
            WHERE b.cempres = e.cempres
              AND b.cmarca = e.cmarca
              AND b.sperson = e.sperson)
UNION
SELECT a.caacion
  FROM agr_marcas a,
       per_agr_marcas b,
       per_personas_rel pr,
       per_detper i,
       estper_personas m,
       esttomadores g,
       per_personas_rel pr1,
       estper_personas n,
       esttomadores g1
 WHERE a.cempres = b.cempres
   AND a.cmarca = b.cmarca
   AND NVL (b.ctomador, 0) = 1
   AND pr.sperson_rel = i.sperson
   AND pr.ctipper_rel = 0
   AND pr.sperson = m.spereal
   AND m.sperson = g.sperson
   AND g.sseguro = psseguro
   AND m.sseguro = psseguro
   AND b.sperson = pr1.sperson
   AND pr1.ctipper_rel = 0
   AND pr1.sperson = n.spereal
   AND n.sperson = g1.sperson
   AND g1.sseguro = psseguro
   AND n.sseguro = psseguro
   AND a.cempres = pcempres
   AND b.nmovimi =
          (SELECT MAX (nmovimi)
             FROM per_agr_marcas e
            WHERE b.cempres = e.cempres
              AND b.cmarca = e.cmarca
              AND b.sperson = e.sperson)
UNION
SELECT a.caacion
  FROM agr_marcas a,
       per_agr_marcas b,
       per_personas_rel pr,
       per_detper i,
       per_personas_rel pr1,
       estper_personas f,
       estassegurats g,
       estper_personas f1,
       estassegurats g1
 WHERE a.cempres = b.cempres
   AND a.cmarca = b.cmarca
   AND b.sperson = pr1.sperson
   AND pr1.ctipper_rel = 0
   AND pr1.sperson = f.spereal
   AND f.sperson = g.sperson
   AND f.sseguro = g.sseguro
   AND g.sseguro = psseguro
    and f_consorcio(b.sperson) = 1
   AND pr.sperson_rel = i.sperson
   AND NVL (pr.cagrupa, 1) = 1
   AND pr.ctipper_rel = 0
   AND NVL (a.casegurado, 0) = 1
   AND pr.sperson = f1.spereal
   AND f1.sperson = g1.sperson
   AND f1.sseguro = g1.sseguro
   AND g1.sseguro = psseguro
   AND a.cempres = pcempres
   AND b.nmovimi =
          (SELECT MAX (nmovimi)
             FROM per_agr_marcas e
            WHERE b.cempres = e.cempres
              AND b.cmarca = e.cmarca
              AND b.sperson = e.sperson)
                                     
            );

    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'pcempres=' || pcempres||' psseguro='||psseguro||' ptablas:'||ptablas;
    vobject  VARCHAR2(200) := 'pac_md_marcas.f_get_accion_poliza';
    v_accion NUMBER;
  BEGIN

     IF (ptablas = 'EST') THEN
        OPEN cur_accion;
        FETCH cur_accion INTO v_accion;
        CLOSE cur_accion;


       END IF;
    --

    RETURN v_accion;

  EXCEPTION
    WHEN OTHERS THEN
          pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
    RETURN -1;

  END f_get_accion_poliza;

--
END pac_md_marcas;

/
