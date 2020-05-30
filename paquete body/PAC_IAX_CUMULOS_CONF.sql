--------------------------------------------------------
--  DDL for Package Body PAC_IAX_CUMULOS_CONF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_IAX_CUMULOS_CONF" AS
  /******************************************************************************
        NOMBRE:       PAC_IAX_CUMULOS_CONF
        PROP¿SITO:  Funciones para gestionar los cumulos

        REVISIONES:
        Ver        Fecha        Autor   Descripci¿n
       ---------  ----------  ------   ------------------------------------
        1.0        01/08/2016   HRE     1. Creaci¿n del package.
  ******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   /*************************************************************************
   FUNCTION f_get_tipcum
   Devuelve el tipo de cumulo del tomador principal de la poliza
   param out mensajes : mensajes de error
   return             : objeto tomador
   *************************************************************************/
   FUNCTION f_get_tipcum(mensajes OUT t_iax_mensajes)
   RETURN NUMBER IS
      v_sproduc      productos.sproduc%type;
      num_err        NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(100) := '';
      vobject        VARCHAR2(200) := 'PAC_IAX_PRODUCCION.F_Get_Tomador';
      v_tipcum       codicontratos.ctipcum%TYPE;
      rg_productos   productos%ROWTYPE;

      CURSOR cur_tipcum(pctipseg productos.ctipseg%TYPE,
                        pccolect productos.ccolect%TYPE,
                        pcmodali productos.cmodali%TYPE,
                        pcramo productos.cramo%TYPE) IS
      SELECT ctipcum
        FROM codicontratos
       WHERE ctiprea in (1, 2, 5)
         AND cvalid = 0
         AND scontra IN (SELECT scontra
                           FROM contratos
                          WHERE TRUNC(f_sysdate) >=  fconini
                            AND (TRUNC(f_sysdate) <=  fconfin
                                 OR fconfin IS NULL )
                        )
         AND scontra IN (SELECT scontra
                           FROM agr_contratos
                          WHERE (ctipseg = pctipseg
                                OR ctipseg IS NULL)
                            AND (ccolect = pccolect
                                OR ccolect IS NULL)
                            AND (cmodali = pcmodali
                                OR cmodali IS NULL)
                            AND cramo = pcramo);

   BEGIN
      IF pac_iax_produccion.poliza.det_poliza IS NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000644);
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      v_sproduc := pac_iax_produccion.vproducto;

      IF mensajes IS NOT NULL THEN
         IF mensajes.COUNT > 0 THEN
            vpasexec := 3;
            RAISE e_object_error;
         END IF;
      END IF;

      vpasexec := 4;

      IF v_sproduc IS NOT NULL THEN
        SELECT *
          INTO rg_productos
          FROM productos
        WHERE sproduc = v_sproduc;

        OPEN cur_tipcum(rg_productos.ctipseg,
                        rg_productos.ccolect,
                        rg_productos.cmodali,
                        rg_productos.cramo);
        FETCH cur_tipcum INTO v_tipcum;
        CLOSE cur_tipcum;

        vpasexec := 5;
        RETURN v_tipcum;
      END IF;

      vpasexec := 6;
      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9000828);
      RETURN NULL;
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


   END f_get_tipcum;
  /*************************************************************************
   Devuelve el objeto tomador de la poliza actual
   param out mensajes : mensajes de error
   return             : objeto tomador
   *************************************************************************/
   FUNCTION f_get_tomador(mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      toma           t_iax_tomadores;
      num_err        NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(100) := '';
      vobject        VARCHAR2(200) := 'PAC_IAX_PRODUCCION.F_Get_Tomador';
      v_tomador      per_personas.sperson%TYPE;
      v_sperson      per_personas.sperson%TYPE;

   BEGIN
      IF pac_iax_produccion.poliza.det_poliza IS NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000644);
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      toma := pac_iobj_prod.f_partpoltomadores(pac_iax_produccion.poliza.det_poliza, mensajes);

      IF toma IS NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9001022);
         vpasexec := 3;
         RAISE e_object_error;
      ELSE
         IF toma.COUNT = 0 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9001022);
            vpasexec := 4;
            RAISE e_object_error;
         END IF;
      END IF;

      IF mensajes IS NOT NULL THEN
         IF mensajes.COUNT > 0 THEN
            vpasexec := 5;
            RAISE e_object_error;
         END IF;
      END IF;

      vpasexec := 6;

         IF toma.EXISTS(1) THEN
            vpasexec := 8;
            v_sperson := toma(1).sperson;

            SELECT spereal
              INTO v_tomador
              FROM estper_personas
             WHERE sperson = v_sperson;

            RETURN v_tomador;
         END IF;

      vpasexec := 10;
      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9000828);
      RETURN NULL;
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
   END f_get_tomador;
  /*************************************************************************
    FUNCTION f_get_cum_tomador
    Permite obtener los cumulos del tomador
    param in pfcorte        : Fecha de corte
    param in ptcumulo       : Tipo de cumulo
    param in pnnumide       : Documento del tomador
    param out ptcum_tomador : Tabla de objetos de cumulo de tomador
    param out mensajes      : mesajes de error
    return                  : number
   *************************************************************************/
   FUNCTION f_get_cum_tomador(pfcorte        IN     DATE,
                              ptcumulo       IN     VARCHAR2,
                              pnnumide       IN     VARCHAR2,
                              mensajes       IN OUT t_iax_mensajes)
   RETURN SYS_REFCURSOR IS
      cur      sys_refcursor;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(2000) := 'pfcorte=' || pfcorte||'-ptcumulo='||ptcumulo||'-pnnumide='||pnnumide;
      vobject  VARCHAR2(200) := 'pac_iax_cumulos_conf.f_get_cum_tomador';
   BEGIN
      cur := pac_md_cumulos_conf.f_get_cum_tomador(pfcorte, ptcumulo, pnnumide, mensajes);
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
   END f_get_cum_tomador;

  /*************************************************************************
    FUNCTION f_get_cum_consorcio
    Permite obtener los cumulos del tomador
    param in pfcorte        : Fecha de corte
    param in ptcumulo       : Tipo de cumulo
    param in pnnumide       : Documento del tomador
    param out ptcum_tomador : Tabla de objetos de cumulo de tomador
    param out mensajes      : mesajes de error
    return                  : number
   *************************************************************************/
   FUNCTION f_get_cum_consorcio(pfcorte        IN     DATE,
                              ptcumulo       IN     VARCHAR2,
                              pnnumide       IN     VARCHAR2,
                              mensajes       IN OUT t_iax_mensajes)
   RETURN SYS_REFCURSOR IS
      cur      sys_refcursor;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(2000) := 'pfcorte=' || pfcorte||'-ptcumulo='||ptcumulo||'-pnnumide='||pnnumide;
      vobject  VARCHAR2(200) := 'pac_iax_cumulos_conf.f_get_cum_consorcio';
   BEGIN
      cur := pac_md_cumulos_conf.f_get_cum_consorcio(pfcorte, ptcumulo, pnnumide, mensajes);
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
   END f_get_cum_consorcio;
  /*************************************************************************
    FUNCTION f_get_com_futuros
    Permite obtener las polizas con compromisos futuros de un tomador a
    una fecha de corte.
    param in pfcorte        : Fecha de corte
    param in pnnumide       : Documento del consorcio/tomador
    param in ptipcomp       : Tipo de compromiso 1-Contractual, 2-PostContractual
    param out mensajes      : mesajes de error
    return                  : number
   *************************************************************************/
   FUNCTION f_get_com_futuros(pfcorte        IN     DATE,
                              pnnumide       IN     VARCHAR2,
                              ptipcomp       IN     NUMBER,
                              psperson       IN     NUMBER,
                              mensajes       IN OUT t_iax_mensajes)
   RETURN SYS_REFCURSOR IS
      cur      sys_refcursor;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(2000) := 'pfcorte=' || pfcorte||'-pnnumide='||pnnumide||'-ptipcomp='||ptipcomp;
      vobject  VARCHAR2(200) := 'pac_iax_cumulos_conf.f_get_com_futuros';
   BEGIN
      cur := pac_md_cumulos_conf.f_get_com_futuros(pfcorte, pnnumide, ptipcomp, psperson, mensajes);
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
   END f_get_com_futuros;

/*************************************************************************
    FUNCTION f_get_detcom_futuros
    Permite obtener el detalle de los compromisos futuros de una poliza
    param in psseguro       : numero del seguro
    param in ptipcomp       : Tipo de compromiso 1-Contractual, 2-PostContractual
    param out mensajes      : mesajes de error
    return                  : number
   *************************************************************************/
   FUNCTION f_get_detcom_futuros(psseguro       IN     NUMBER,
                                 ptipcomp       IN     NUMBER,
                                 pfcorte        IN     DATE,
                                 psperson       IN     NUMBER,
                                 mensajes       IN OUT t_iax_mensajes)
   RETURN SYS_REFCURSOR IS
      cur      sys_refcursor;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(2000) := 'psseguro='||psseguro||'-ptipcomp='||ptipcomp||'-pfcorte='||pfcorte;
      vobject  VARCHAR2(200) := 'pac_iax_cumulos_conf.f_get_detcom_futuros';
   BEGIN
      cur := pac_md_cumulos_conf.f_get_detcom_futuros(psseguro, ptipcomp, pfcorte, psperson, mensajes);
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
   END f_get_detcom_futuros;
/*************************************************************************
    FUNCTION f_get_pinta_contratos
    Permite identificar cuales cuotas se pintan o no en el java.
    param in pfcorte        : Fecha de corte
    param in ptcumulo       : Tipo de cumulo
    param in pnnumide       : Documento del consorcio/tomador
    param out mensajes      : mesajes de error
    return                  : number
   *************************************************************************/
   FUNCTION f_get_pinta_contratos(pfcorte        IN     DATE,
                                  ptcumulo       IN     VARCHAR2,
                                  pnnumide       IN     VARCHAR2,
                                  mensajes       IN OUT t_iax_mensajes)
   RETURN SYS_REFCURSOR IS
      cur      sys_refcursor;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(2000) := 'ptcumulo='||ptcumulo||'-pnnumide='||pnnumide||'-pfcorte='||pfcorte;
      vobject  VARCHAR2(200) := 'pac_iax_cumulos_conf.f_get_pinta_contratos';
   BEGIN
      cur := pac_md_cumulos_conf.f_get_pinta_contratos(pfcorte, ptcumulo, pnnumide, mensajes);
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
   END f_get_pinta_contratos;
  /*************************************************************************
    FUNCTION f_get_cum_tomador_serie
    Permite obtener los cumulos del tomador por anio/seria
    param in pfcorte        : Fecha de corte
    param in ptcumulo       : Tipo de cumulo
    param in pnnumide       : Documento del tomador
    param out ptcum_tomador : Tabla de objetos de cumulo de tomador
    param out mensajes      : mesajes de error
    return                  : number
   *************************************************************************/
   FUNCTION f_get_cum_tomador_serie(pfcorte        IN     DATE,
                                    ptcumulo       IN     VARCHAR2,
                                    pnnumide       IN     VARCHAR2,
                                    mensajes       IN OUT t_iax_mensajes)
   RETURN SYS_REFCURSOR IS
      cur      sys_refcursor;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(2000) := 'pfcorte=' || pfcorte||'-ptcumulo='||ptcumulo||'-pnnumide='||pnnumide;
      vobject  VARCHAR2(200) := 'pac_iax_cumulos_conf.f_get_cum_tomador_serie';
   BEGIN
      cur := pac_md_cumulos_conf.f_get_cum_tomador_serie(pfcorte, ptcumulo, pnnumide, mensajes);
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
   END f_get_cum_tomador_serie;

  /*************************************************************************
    FUNCTION f_get_cum_tomador_pol
    Permite obtener los cumulos del tomador por poliza
    param in pfcorte        : Fecha de corte
    param in ptcumulo       : Tipo de cumulo
    param in pnnumide       : Documento del tomador
    param out ptcum_tomador : Tabla de objetos de cumulo de tomador
    param out mensajes      : mesajes de error
    return                  : number
   *************************************************************************/
   FUNCTION f_get_cum_tomador_pol(pfcorte        IN     DATE,
                                    ptcumulo       IN     VARCHAR2,
                                    pnnumide       IN     VARCHAR2,
                                    mensajes       IN OUT t_iax_mensajes)
   RETURN SYS_REFCURSOR IS
      cur      sys_refcursor;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(2000) := 'pfcorte=' || pfcorte||'-ptcumulo='||ptcumulo||'-pnnumide='||pnnumide;
      vobject  VARCHAR2(200) := 'pac_iax_cumulos_conf.f_get_cum_tomador_pol';
   BEGIN
      cur := pac_md_cumulos_conf.f_get_cum_tomador_pol(pfcorte, ptcumulo, pnnumide, mensajes);
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
   END f_get_cum_tomador_pol;

   /*************************************************************************
    FUNCTION f_set_depuracion_manual
    Permite generar el registro de depuracion manual
    param in pfcorte        : Fecha de corte
    param in ptcumulo       : Tipo de cumulo
    param in pnnumide       : Documento del tomador
    param out mensajes      : mesajes de error
    return                  : number
   *************************************************************************/
   FUNCTION f_set_depuracion_manual(psseguro       IN     NUMBER,
                                    pcgenera       IN     NUMBER,
                                    pcgarant       IN     NUMBER,
                                    pindicad       IN     VARCHAR2,
                                    pvalor         IN     NUMBER,
                                    mensajes       IN OUT t_iax_mensajes)
   RETURN NUMBER IS
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'psseguro=' || psseguro||' pcgenera='||pcgenera||' pcgarant:'||pcgarant
                               ||' pindicad:'||pindicad||' pvalor:'||pvalor;
    vobject  VARCHAR2(200) := 'pac_iax_cumulos_conf.f_set_depuracion_manual';
    vnumerr  NUMBER (8):=0;

    BEGIN
      p_control_error('pac_iax_cumulos', 'f_set_depuracion_manual','paso 1');    
      vnumerr := pac_md_cumulos_conf.f_set_depuracion_manual(psseguro, pcgenera, pcgarant, pindicad, pvalor, mensajes);

	    IF vnumerr<>0 THEN
	      RAISE e_object_error;
	    END IF;

	    COMMIT;
	    RETURN 0;
	EXCEPTION
    WHEN e_object_error THEN
       pac_iobj_mensajes.p_tratarmensaje (mensajes, vobject, 1000006, vpasexec, vparam);
       ROLLBACK;
       RETURN 1;
    WHEN OTHERS THEN
       pac_iobj_mensajes.p_tratarmensaje (mensajes, vobject, 1000001, vpasexec, vparam, psqcode=>SQLCODE, psqerrm=>SQLERRM);
       ROLLBACK;
       RETURN 1;
  END f_set_depuracion_manual;

/*************************************************************************
    FUNCTION f_get_depuracion_manual
    Permite obtener las depuraciones manuales de un tomador
    param in pfcorte        : fecha de corte
    param in pnnumide       : numero de documento
    param out mensajes      : mesajes de error
    return                  : number
   *************************************************************************/
   FUNCTION f_get_depuracion_manual(pfcorte        IN     DATE,
                                    pnnumide       IN     VARCHAR2,
                                    psperson       IN     NUMBER,
                                    mensajes       IN OUT t_iax_mensajes)
   RETURN SYS_REFCURSOR IS
      cur      sys_refcursor;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(2000) := 'pfcorte=' || pfcorte||'-pnnumide='||pnnumide;
      vobject  VARCHAR2(200) := 'pac_iax_cumulos_conf.f_get_depuracion_manual';
   BEGIN
      cur := pac_md_cumulos_conf.f_get_depuracion_manual(pfcorte, pnnumide, psperson, mensajes);
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
END f_get_depuracion_manual;
/*************************************************************************
    FUNCTION f_get_depuracion_manual_serie
    Permite obtener las depuraciones manuales de un tomador por serie/anio
    param in pfcorte        : fecha de corte
    param in pnnumide       : numero de documento
    param in pserie         : serie/anio
    param out mensajes      : mesajes de error
    return                  : number
   *************************************************************************/
   FUNCTION f_get_depuracion_manual_serie(pfcorte        IN     DATE,
                                          pnnumide       IN     VARCHAR2,
                                          pserie         IN     NUMBER,
                                          psperson       IN     NUMBER,
                                          mensajes       IN OUT t_iax_mensajes)
   RETURN SYS_REFCURSOR IS
      cur      sys_refcursor;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(2000) := 'pfcorte=' || pfcorte||'-pnnumide='||pnnumide||'-pserie='||pserie;
      vobject  VARCHAR2(200) := 'pac_iax_cumulos_conf.f_get_depuracion_manual';
   BEGIN
      cur := pac_md_cumulos_conf.f_get_depuracion_manual_serie(pfcorte, pnnumide, pserie, psperson, mensajes);
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
END f_get_depuracion_manual_serie;

END pac_iax_cumulos_conf;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_CUMULOS_CONF" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_CUMULOS_CONF" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_CUMULOS_CONF" TO "PROGRAMADORESCSI";
