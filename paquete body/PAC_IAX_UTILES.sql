--------------------------------------------------------
--  DDL for Package Body PAC_IAX_UTILES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_IAX_UTILES" IS
   /******************************************************************************
      NOMBRE:    PAC_IAX_UTILES
      PROP真SITO: Funciones con utilidades transversales

      REVISIONES:
      Ver        Fecha        Autor             Descripci真n
      ---------  ----------  ---------------  ------------------------------------
      1.0        12/10/2016  JAE              1. Creaci真nn del objeto.
      2.0        21/06/2019   SGM             2. IAXIS-4134 Reporte de acuerdo de pago
   ******************************************************************************/

   /*************************************************************************
      Retorna el importe aplicando la tasa de cambio
      param in  p_moneda_inicial : Moneda origen
      param in  p_moneda_final   : Moneda destino
      param in  p_fecha          : Fecha de cambio
      param in  p_importe        : Valor
      param in  p_redondear      : Redondear. Defecto 1
      param out p_cambio         : Tasa de cambio
      param out mensajes         : mensajes de error
      return                     : Importe aplicando tasa de cambio
   *************************************************************************/
   FUNCTION f_importe_cambio(p_moneda_inicial IN eco_tipocambio.cmonori%TYPE,
                             p_moneda_final   IN OUT eco_tipocambio.cmondes%TYPE,
                             p_fecha          IN eco_tipocambio.fcambio%TYPE,
                             p_importe        IN NUMBER,
                             p_cambio         OUT NUMBER,
                             mensajes         OUT t_iax_mensajes)
      RETURN NUMBER IS
      --
      vpasexec NUMBER := 1;
      vobject  VARCHAR2(200) := 'pac_iax_utiles.f_importe_cambio';
      vparam   VARCHAR2(500);
      --
   BEGIN
      --
      RETURN pac_md_utiles.f_importe_cambio(p_moneda_inicial => p_moneda_inicial,
                                            p_moneda_final   => p_moneda_final,
                                            p_fecha          => p_fecha,
                                            p_importe        => p_importe,
                                            p_cambio         => p_cambio,
                                            mensajes         => mensajes);
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000005,
                                           vpasexec,
                                           vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000006,
                                           vpasexec,
                                           vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           psqcode  => SQLCODE,
                                           psqerrm  => SQLERRM);
         RETURN 1;
   END f_importe_cambio;

   /*************************************************************************
      FUNCTION f_get_user_comp: Retorna la informaci真n usu_datos

      param in pscontgar : Agente
      param in mensajes  : t_iax_mensajes
      return             : sys_refcursor
   *************************************************************************/
   FUNCTION f_get_user_comp(pcuser   IN VARCHAR2,
                            mensajes OUT t_iax_mensajes) RETURN SYS_REFCURSOR IS
      --
      vpasexec NUMBER;
      vobject  VARCHAR2(200) := 'pac_iax_utiles.f_get_user_comp';
      vparam   VARCHAR2(500) := 'pcuser: ' || pcuser;
      --
   BEGIN
      --
      RETURN pac_md_utiles.f_get_user_comp(pcuser   => pcuser,
                                           mensajes => mensajes);
      --
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000005,
                                           vpasexec,
                                           vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000006,
                                           vpasexec,
                                           vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           psqcode  => SQLCODE,
                                           psqerrm  => SQLERRM);
         RETURN NULL;
   END f_get_user_comp;

   /*************************************************************************
      FUNCTION f_get_hisprocesosrea: Retorna la informaci真n de hisprocesosrea

      param in pcnomtabla   : Nombre tabla
      param in pcnomcampo   : Nombre campo
      param in pcusuariomod : Usuario modifica
      param in pfmodifi_ini : Fecha inicio
      param in pfmodifi_fin :  Fecha fin
      param in mensajes     : t_iax_mensajes
      return                : sys_refcursor
   *************************************************************************/
   FUNCTION f_get_hisprocesosrea(pcnomtabla   IN VARCHAR2,
                                 pcnomcampo   IN VARCHAR2,
                                 pcusuariomod IN VARCHAR2,
                                 pfmodifi_ini DATE,
                                 pfmodifi_fin DATE,
                                 mensajes     OUT t_iax_mensajes)
      RETURN SYS_REFCURSOR IS
      --
      vpasexec NUMBER;
      vobject  VARCHAR2(200) := 'pac_md_utiles.f_get_hisprocesosrea';
      vparam   VARCHAR2(500) := 'pcnomtabla: ' || pcnomtabla ||
                                ' pcnomcampo: ' || pcnomcampo ||
                                ' pcusuariomod: ' || pcusuariomod ||
                                ' pfmodifi_ini: ' || pfmodifi_ini ||
                                ' pfmodifi_fin: ' || pfmodifi_fin;
      --
   BEGIN
      --
      RETURN pac_md_utiles.f_get_hisprocesosrea(pcnomtabla   => pcnomtabla,
                                                pcnomcampo   => pcnomcampo,
                                                pcusuariomod => pcusuariomod,
                                                pfmodifi_ini => pfmodifi_ini,
                                                pfmodifi_fin => pfmodifi_fin,
                                                mensajes     => mensajes);
      --
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000005,
                                           vpasexec,
                                           vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000006,
                                           vpasexec,
                                           vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           psqcode  => SQLCODE,
                                           psqerrm  => SQLERRM);
         RETURN NULL;
   END f_get_hisprocesosrea;

  FUNCTION f_set_acuerdo_prima(
            pnnumide IN VARCHAR2,
            ptomador IN VARCHAR2,
            pcodsucursal IN NUMBER,
            psucursal IN VARCHAR2,
            pdireccion IN VARCHAR2,
            ptelefono_fijo IN VARCHAR2,
            ptelefono_celular IN VARCHAR2,
            pnnumide_rep IN VARCHAR2,
            prepresentante IN VARCHAR2,
            pvalor IN NUMBER,
            plugar IN VARCHAR2,
            pfecha IN DATE,
            pnro_cuotas IN NUMBER,
            pcrepresentante IN NUMBER,
            pidacuerdo out number,
            pcusuario IN VARCHAR2, --JRVG 5319 REPORTE ACUERDOS DE PAGO
            mensajes OUT t_iax_mensajes
      )
        RETURN NUMBER IS
        vnumerr        NUMBER(8) := 0;

        vpasexec NUMBER := 1;
        vobject  VARCHAR2(200) := 'pac_md_utiles.f_set_acuerdo_prima';
        vparam   VARCHAR2(500);

         BEGIN

          vnumerr := pac_md_utiles.f_set_acuerdo_prima( pnnumide    => pnnumide,
                                                    ptomador    => ptomador,
                                                    pcodsucursal   => pcodsucursal,
                                                    psucursal   => psucursal,
                                                    pdireccion   => pdireccion,
                                                    ptelefono_fijo   => ptelefono_fijo,
                                                    ptelefono_celular   => ptelefono_celular,
                                                    pnnumide_rep   => pnnumide_rep,
                                                    prepresentante   => prepresentante,
                                                    pvalor   => pvalor,
                                                    plugar   => plugar,
                                                    pfecha   => pfecha,
                                                    pnro_cuotas   => pnro_cuotas,
                                                    pcrepresentante   => pcrepresentante,
                                                    pidacuerdo   => pidacuerdo,
                                                    pcusuario => pcusuario, --JRVG 5319 REPORTE ACUERDOS DE PAGO
                                                    mensajes   => mensajes );


          COMMIT;
          RETURN vnumerr;

           EXCEPTION
                WHEN e_param_error THEN
                   pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                                     vobject,
                                                     1000005,
                                                     vpasexec,
                                                     vparam);
                   RETURN 1;
                WHEN e_object_error THEN
                   pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                                     vobject,
                                                     1000006,
                                                     vpasexec,
                                                     vparam);
                   RETURN 1;
                WHEN OTHERS THEN
                   pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                                     vobject,
                                                     1000001,
                                                     vpasexec,
                                                     vparam,
                                                     psqcode  => SQLCODE,
                                                     psqerrm  => SQLERRM);
                   RETURN 1;

     END f_set_acuerdo_prima;

    FUNCTION f_set_det_acuerdo_prima(
          pidacuerdo IN NUMBER,
          pnro_cuota IN NUMBER,
          pporcentaje IN NUMBER,
          pvalor IN NUMBER,
          pfecha_pago IN DATE,
          mensajes OUT t_iax_mensajes
      )
        RETURN NUMBER IS
        vnumerr        NUMBER(8) := 0;
          vpasexec NUMBER := 1;
          vobject  VARCHAR2(200) := 'pac_md_utiles.f_set_det_acuerdo_prima';
          vparam   VARCHAR2(500);

         BEGIN

          vnumerr := pac_md_utiles.f_set_det_acuerdo_prima( pidacuerdo    => pidacuerdo,
                                                        pnro_cuota    => pnro_cuota,
                                                        pporcentaje   => pporcentaje,
                                                        pvalor   => pvalor,
                                                        pfecha_pago   => pfecha_pago,
                                                        mensajes   => mensajes);

         COMMIT;
          RETURN vnumerr;


           EXCEPTION
                WHEN e_param_error THEN
                   pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                                     vobject,
                                                     1000005,
                                                     vpasexec,
                                                     vparam);
                   RETURN 1;
                WHEN e_object_error THEN
                   pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                                     vobject,
                                                     1000006,
                                                     vpasexec,
                                                     vparam);
                   RETURN 1;
                WHEN OTHERS THEN
                   pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                                     vobject,
                                                     1000001,
                                                     vpasexec,
                                                     vparam,
                                                     psqcode  => SQLCODE,
                                                     psqerrm  => SQLERRM);
                   RETURN 1;

     END f_set_det_acuerdo_prima;

     FUNCTION f_set_polizas_acuerdo_prima(
          pidacuerdo IN NUMBER,
          npoliza IN VARCHAR2,--SGM 4134 REPORTE CUOTAS ACUERDOS DE PAGO
          nrecibo IN VARCHAR2,--SGM 4134 REPORTE CUOTAS ACUERDOS DE PAGO
          nsaldo IN NUMBER,
          pvalor IN NUMBER,
          mensajes OUT t_iax_mensajes
      )
        RETURN NUMBER IS
       vnumerr        NUMBER(8) := 0;
          vpasexec NUMBER := 1;
          vobject  VARCHAR2(200) := 'pac_md_utiles.f_set_polizas_acuerdo_prima';
          vparam   VARCHAR2(500);

         BEGIN

          vnumerr := pac_md_utiles.f_set_polizas_acuerdo_prima( pidacuerdo    => pidacuerdo,
                                                            npoliza    => npoliza,
                                                            nrecibo   => nrecibo,
                                                            nsaldo    => nsaldo,
                                                            pvalor   => pvalor,
                                                            mensajes   => mensajes);
           COMMIT;
          RETURN vnumerr;


           EXCEPTION
                WHEN e_param_error THEN
                   pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                                     vobject,
                                                     1000005,
                                                     vpasexec,
                                                     vparam);
                   RETURN 1;
                WHEN e_object_error THEN
                   pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                                     vobject,
                                                     1000006,
                                                     vpasexec,
                                                     vparam);
                   RETURN 1;
                WHEN OTHERS THEN
                   pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                                     vobject,
                                                     1000001,
                                                     vpasexec,
                                                     vparam,
                                                     psqcode  => SQLCODE,
                                                     psqerrm  => SQLERRM);
                   RETURN 1;

     END f_set_polizas_acuerdo_prima;
	 
	 FUNCTION f_get_tipiva(
          psseguro IN NUMBER,
          pnriesgo IN NUMBER,
          vtipiva out number,
          mensajes OUT t_iax_mensajes
      )
        RETURN NUMBER IS
       vnumerr        NUMBER(8) := 0;
          vpasexec NUMBER := 1;
          vobject  VARCHAR2(200) := 'pac_iax_utiles.f_get_tipiva';
          vparam   VARCHAR2(500);

         BEGIN

          vnumerr := pac_md_utiles.f_get_tipiva( psseguro    => psseguro,
                                                 pnriesgo    => pnriesgo,
                                                 vtipiva     => vtipiva,
                                                 mensajes   => mensajes);
          RETURN vnumerr;


           EXCEPTION
                WHEN e_param_error THEN
                   pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                                     vobject,
                                                     1000005,
                                                     vpasexec,
                                                     vparam);
                   RETURN 1;
                WHEN e_object_error THEN
                   pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                                     vobject,
                                                     1000006,
                                                     vpasexec,
                                                     vparam);
                   RETURN 1;
                WHEN OTHERS THEN
                   pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                                     vobject,
                                                     1000001,
                                                     vpasexec,
                                                     vparam,
                                                     psqcode  => SQLCODE,
                                                     psqerrm  => SQLERRM);
                   RETURN 1;

     END f_get_tipiva;
	 
	 FUNCTION f_get_ultmov(
          psseguro IN NUMBER,
          ptipo IN NUMBER,
          vultmov out number,
          mensajes OUT t_iax_mensajes
      ) RETURN NUMBER IS
      
          vpasexec NUMBER := 1;
          vobject  VARCHAR2(200) := 'pac_iax_utiles.f_get_ultmov';
          vparam   VARCHAR2(500);

         BEGIN

          vultmov := PAC_ISQLFOR_CONF.f_get_ultmov(psseguro,ptipo);
          
          RETURN 0;


           EXCEPTION
                WHEN e_param_error THEN
                   pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                                     vobject,
                                                     1000005,
                                                     vpasexec,
                                                     vparam);
                   RETURN 1;
                WHEN e_object_error THEN
                   pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                                     vobject,
                                                     1000006,
                                                     vpasexec,
                                                     vparam);
                   RETURN 1;
                WHEN OTHERS THEN
                   pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                                     vobject,
                                                     1000001,
                                                     vpasexec,
                                                     vparam,
                                                     psqcode  => SQLCODE,
                                                     psqerrm  => SQLERRM);
                   RETURN 1;

     END f_get_ultmov;
	 
END pac_iax_utiles;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_UTILES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_UTILES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_UTILES" TO "PROGRAMADORESCSI";
