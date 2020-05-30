--------------------------------------------------------
--  DDL for Package Body PAC_MD_PROCESOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MD_PROCESOS" IS
/******************************************************************************
   NOMBRE:    PAC_MD_PROCESOS
   PROPÓSITO:

   REVISIONES:
   Ver        Fecha       Autor  Descripción
   ---------  ----------  -----  ------------------------------------
   1.0        22/02/10    JRB     Creació del package.

******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   /***********************************************************************
      Comentarios
      param in  pSPROCES     : NUMBER
      param in  pFPROINI     : DATE
      param in  pCPROCES     : NUMBER
      param in  pNERROR      : NUMBER
      param in  pCUSUARI     : VARCHAR2
      param in out mensajes : T_IAX_MENSAJES
      return                : ref cursor
   ***********************************************************************/
   FUNCTION f_set_consultaprocesoscab(
      pcempres IN NUMBER,
      psproces IN NUMBER,
      pfproini IN DATE,
      pcproces IN VARCHAR2,
      pnerror IN NUMBER,
      pcusuari IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_procesoscab IS
      cur            sys_refcursor;
      procesoss      t_iax_procesoscab := t_iax_procesoscab();
      procesos       ob_iax_procesoscab := ob_iax_procesoscab();
      squery         VARCHAR2(2000);
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(250)
         := 'param: - CEMPRES : ' || pcempres || ' - SPROCES : ' || psproces
            || ' - FPROINI : ' || pfproini || ' - CPROCES : ' || pcproces || ' - NERROR : '
            || pnerror || ' - CUSUARI : ' || pcusuari;
      vobject        VARCHAR2(200) := 'PAC_MD_PROCESOS.F_Set_ConsultaPROCESOSCAB';
      buscar         VARCHAR2(4000) := '';
   BEGIN
      IF psproces IS NOT NULL THEN
         buscar := buscar || ' and SPROCES = ' || psproces;
      END IF;

      IF pfproini IS NOT NULL THEN
         buscar := buscar || ' and TRUNC(FPROINI) like TRUNC(to_date(''' || pfproini || '''))';
      END IF;

      IF pcproces IS NOT NULL THEN
         --buscar := buscar || ' and UPPER(CPROCES) LIKE UPPER(''%' || pcproces || '%'') ';
         buscar := buscar || ' and UPPER(CPROCES) LIKE UPPER(''%' || ff_strstd(pcproces)
                   || '%'') ';   -- BUG 38344/217178 - 05/11/2015 - ACL
      END IF;

      IF pnerror IS NOT NULL THEN
         buscar := buscar || ' and NERROR = ' || pnerror;
      END IF;

      IF pcusuari IS NOT NULL THEN
         --buscar := buscar || ' and CUSUARI = ''' || pcusuari || '''';
         buscar := buscar || ' and UPPER(CUSUARI) LIKE UPPER(''%' || ff_strstd(pcusuari)
                   || '%'') ';   -- BUG 38344/217178 - 05/11/2015 - ACL
      END IF;

      squery :=
         'SELECT SPROCES,P.CEMPRES,E.TEMPRES,CUSUARI,FPROINI,CPROCES,NERROR,TPROCES,FPROFIN
                 FROM PROCESOSCAB P, EMPRESAS E where P.CEMPRES = E.CEMPRES AND rownum < 102 AND P.CEMPRES = '
         || pcempres || buscar || ' order by SPROCES desc';
      vpasexec := 2;
      p_tab_error(f_sysdate, f_user, vobject, vpasexec, SQLERRM, squery);
      cur := pac_iax_listvalores.f_opencursor(squery, mensajes);
      vpasexec := 3;

      LOOP
         FETCH cur
          INTO procesos.sproces, procesos.cempres, procesos.tempres, procesos.cusuari,
               procesos.fproini, procesos.cproces, procesos.nerror, procesos.tproces,
               procesos.fprofin;

         EXIT WHEN cur%NOTFOUND;
         procesoss.EXTEND;
         procesoss(procesoss.LAST) := procesos;
         procesos := ob_iax_procesoscab();
      END LOOP;

      CLOSE cur;

      RETURN procesoss;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN NULL;
   END f_set_consultaprocesoscab;

/***********************************************************************
      Comentarios
      param in out mensajes : T_IAX_MENSAJES
      return                : ref cursor
   ***********************************************************************/
   FUNCTION f_set_consultaprocesoslin(psproces IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_procesoslin IS
      cur            sys_refcursor;
      procesoss      t_iax_procesoslin := t_iax_procesoslin();
      procesos       ob_iax_procesoslin := ob_iax_procesoslin();
      squery         VARCHAR2(2000);
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(250) := 'param: - SPROCES : ' || psproces;
      vobject        VARCHAR2(200) := 'PAC_MD_PROCESOS.F_Set_ConsultaPROCESOSLIN';
   BEGIN
      squery :=
         'SELECT p.SPROCES,p.NPROLIN,p.NPRONUM,p.TPROLIN,p.FPROLIN,p.CESTADO,p.CTIPLIN, d.tatribu, to_char(p.fprolin,''dd/mm/yyyy'') tfprolin
         , decode(s.npoliza,NULL,'''',s.npoliza || ''-'' || s.ncertif) tpoliza
                 FROM PROCESOSLIN p, detvalores d, seguros s WHERE SPROCES = '
         || psproces || ' and d.cvalor = 713 and d.cidioma = '
         || pac_md_common.f_get_cxtidioma || ' and d.catribu = p.ctiplin'
         || ' and s.sseguro (+) = p.npronum ';
      vpasexec := 2;
      cur := pac_iax_listvalores.f_opencursor(squery, mensajes);

      LOOP
         FETCH cur
          INTO procesos.sproces, procesos.nprolin, procesos.npronum, procesos.tprolin,
               procesos.fprolin, procesos.cestado, procesos.ctiplin, procesos.ttiplin,
               procesos.tfprolin, procesos.tpoliza;

         EXIT WHEN cur%NOTFOUND;
         procesoss.EXTEND;
         procesoss(procesoss.LAST) := procesos;
         procesos := ob_iax_procesoslin();
      END LOOP;

      CLOSE cur;

      RETURN procesoss;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN NULL;
   END f_set_consultaprocesoslin;
END pac_md_procesos;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_PROCESOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_PROCESOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_PROCESOS" TO "PROGRAMADORESCSI";
