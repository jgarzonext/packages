--------------------------------------------------------
--  DDL for Package Body PAC_IAX_FE_VIDA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_IAX_FE_VIDA" AS
/******************************************************************************
   NOMBRE:       PAC_IAX_FE_VIDA
   PROPÓSITO:  Funciones necesarias para la generacion de las Cartas de Fe de Vida

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
    1.0        07/09/2010   ETM              1. Creación del package.--0015884: CEM - Fe de Vida. Nuevos paquetes PLSQL
    2.0        19/01/2011   APD              2. Bug 15289 : Cartas Fe de Vida
   ******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;
   mensajes       t_iax_mensajes := NULL;

-- Bug 15289 - APD - 21/01/2011 - se crea la funcion
   /*************************************************************************
   Función  F_PERCEPTORES_RENTA
   Devuelve las personas que reciben la renta.
   Solo se mostraran aquellas personas a las cuales se les ha enviado la carta de
   fe de vida previamente y que aun no han confirmado su fe de vida
      param in psseguro: identificador del seguro
      param out mensajes : mesajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_perceptores_renta(psseguro IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'psseguro: ' || psseguro;
      vobject        VARCHAR2(200) := 'PAC_IAX_FE_VIDA.f_perceptores_renta';
      cur            sys_refcursor;
      squery         VARCHAR2(1000);
   BEGIN
      IF psseguro IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      cur := pac_md_fe_vida.f_perceptores_renta(psseguro, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, NULL,
                                           SQLCODE, SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_perceptores_renta;

/*******************************************************************************
   FUNCION  F_GET_DATOS_FE_VIDA
   -función qdevolverá un REF CURSOR con las pólizas que deben enviar la carta de fe de vida.
   Parámetros:
    Entrada :
    1.   psproces. Identificador del proceso.
    2.   pcempres. Identificador de la empresa. Obligatorio.
    3.   pcramo. Identificador del ramo.
    4.   psproduc. Identificador del producto.
    5.   pcagente. Identificador del agente.
    6.   pnpoliza. Número de póliza.
    7.   pncertif. Número de certificado.
    8.   pfhasta. Fecha hasta la cual se realiza la solicitud de fe de vida. Obligatorio.
    9.   pngenerar. Identificador de generación de cartas. 0.-Se generan las cartas por primera vez;1.-Se vuelve a reimprimir el listado (map). Obligatorio (valor por defecto 0)
    10.  pnpantalla. Identificador de visualización o no del resultado de la select por pantalla. 0.-No se visualiza el resultado de la select por pantalla (el resultado de la select se utiliza en el map);1.-Sí se visualiza el resultado de la select por pantalla. Obligatorio (valor por defecto 0)

    Salida :
      Mensajes T_IAX_MENSAJES

   Retorna : REF CURSOR.
   ********************************************************************************/
   FUNCTION f_get_datos_fe_vida(
      psproces IN NUMBER,
      pcempres IN NUMBER,
      pcramo IN NUMBER,
      psproduc IN NUMBER,
      pcagente IN NUMBER,
      pnpoliza IN NUMBER,
      pncertif IN NUMBER,
      pfhasta IN DATE,
      pngenerar IN NUMBER DEFAULT 0,
      pnpantalla IN NUMBER DEFAULT 0,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vsproces       NUMBER;
      vcempres       NUMBER;
      vcramo         NUMBER;
      vsproduc       NUMBER;
      vcagente       NUMBER;
      vnpoliza       NUMBER;
      vncertif       NUMBER;
      vfhasta        DATE;
      cur            sys_refcursor;
      vnumerr        NUMBER := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(4000)
         := 'psproces=' || psproces || ' pcempres=' || pcempres || ' pcramo=' || pcramo
            || ' psproduc=' || psproduc || ' pcagente=' || pcagente || ' pnpoliza='
            || pnpoliza || ' pncertif=' || pncertif || ' pfhasta=' || pfhasta || ' pngenerar='
            || pngenerar || ' pnpantalla= ' || pnpantalla;
      vobject        VARCHAR2(200) := 'PAC_IAX_FE_VIDA.f_get_datos_fe_vida';
   BEGIN
      -- comprobar campos obligatorios
      IF pngenerar = 0 THEN
         IF pcempres IS NULL
            OR pfhasta IS NULL THEN
            RAISE e_param_error;
         END IF;
      ELSIF pngenerar = 1 THEN
         IF psproces IS NULL
            OR pcempres IS NULL THEN   -- Bug 15289 - APD - 19/01/2011 - la empresa sí que es necesaria
            RAISE e_param_error;
         END IF;
      END IF;

      vsproces := psproces;
      vcempres := pcempres;
      vcramo := pcramo;
      vsproduc := psproduc;
      vcagente := pcagente;
      vnpoliza := pnpoliza;
      vncertif := pncertif;
      vfhasta := pfhasta;

      -- campos que deben estar informados en funcion del valor de pngenerar
      IF pngenerar = 0 THEN
         -- el sproces no debe estar informado ya que queremos que se generen las cartas
         vsproces := NULL;
      ELSIF pngenerar = 1 THEN
         -- solo debe estar informado el sprcoes
         --vcempres := NULL; -- Bug 15289 - APD - 19/01/2011 - la empresa sí que es necesaria
         vcramo := NULL;
         vsproduc := NULL;
         vcagente := NULL;
         vnpoliza := NULL;
         vncertif := NULL;
         vfhasta := NULL;
      END IF;

      vpasexec := 2;

      -- Si el psproces (¡¡OJO!!! no confundir con vsproces) no está informado sí se puede
      -- llamar a la funcion pac_md_fe_vida.f_get_datos_fe_vida para que devuelva las
      -- pólizas que deben enviar la carta de fe de vida, en caso contrario NO.
      -- Esto se hace para no modificar la pantalla AXISCTR109.-Generar Cartas Fe de Vida.
      -- Lo que se quiere es que si el psproces está informado no muestre los datos
      -- de las polizas en el multiregistro Detalle Cartas Fe de Vida, ya que al filtrar
      -- por un proceso (se ha informado el Proceso en la pantalla de busqueda) los datos
      -- que se quieren consultar se verán al REIMPRIMIR el listado
      IF psproces IS NULL THEN
         cur := pac_md_fe_vida.f_get_datos_fe_vida(vsproces, vcempres, vcramo, vsproduc,
                                                   vcagente, vnpoliza, vncertif, vfhasta,
                                                   pngenerar, pnpantalla, mensajes);
      END IF;

      vpasexec := 3;
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_datos_fe_vida;

   /*******************************************************************************
   FUNCION  F_GENERAR_FE_VIDA
   -función que genera el fichero con las pólizas a las cuales se les debe enviar la carta de fe de vida
       y crea un apunte en la Agenda de dichas pólizas indicando que se ha enviado la carta.
   -Llamará a la función PAC_MD_FE_DE_VIDA.F_GENERAR_FE_VIDA.
   Parámetros:
    Entrada :
        1.  psproces IN. Identificador del proceso. Obligatorio si pngenerar = 1.
        2.  pcempres IN. Identificador de la empresa. Obligatorio.
        3.  pcramo IN. Identificador del ramo.
        4.  psproduc IN. Identificador del producto.
        5.  pcagente IN. Identificador del agente.
        6.  pnpoliza IN. Número de póliza.
        7.  pncertif IN. Número de certificado.
        8.  pfhasta. IN Fecha hasta la cual se realiza la solicitud de fe de vida. Obligatorio.
        9.  pngenerar IN. Identificador de generación de cartas. 0.-Se generan las cartas por primera vez;1.-Se vuelve a reimprimir el listado (map). Obligatorio (valor por defecto 0)
   Salida :
     10. sproces OUT. Identificador del proceso.
      Mensajes T_IAX_MENSAJES

   Retorna : number 0 ok, 1 error
   ********************************************************************************/
   FUNCTION f_generar_fe_vida(
      psproces IN NUMBER,
      pcempres IN NUMBER,
      pcramo IN NUMBER,
      psproduc IN NUMBER,
      pcagente IN NUMBER,
      pnpoliza IN NUMBER,
      pncertif IN NUMBER,
      pfhasta IN DATE,
      pngenerar IN NUMBER DEFAULT 0,
      sproces OUT NUMBER,
      pnomfich OUT VARCHAR2,
      vtimp OUT t_iax_impresion,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vsproces       NUMBER;
      vcempres       NUMBER;
      vcramo         NUMBER;
      vsproduc       NUMBER;
      vcagente       NUMBER;
      vnpoliza       NUMBER;
      vncertif       NUMBER;
      vfhasta        DATE;
      numerr         NUMBER := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(4000)
         := 'psproces=' || psproces || ' pcempres=' || pcempres || ' pcramo=' || pcramo
            || ' psproduc=' || psproduc || ' pcagente=' || pcagente || ' pnpoliza='
            || pnpoliza || ' pncertif=' || pncertif || ' pfhasta='
            || TO_CHAR(pfhasta, 'dd/mm/yyyy') || ' pngenerar=' || pngenerar;
      vobject        VARCHAR2(200) := 'PAC_IAX_FE_VIDA.F_GENERAR_FE_VIDA';
   BEGIN
      IF pngenerar = 0 THEN
         IF pcempres IS NULL
            OR pfhasta IS NULL THEN
            RAISE e_param_error;
         END IF;
      ELSIF pngenerar = 1 THEN
         IF psproces IS NULL
            OR pcempres IS NULL THEN   -- Bug 15289 - APD - 19/01/2011 - la empresa sí que es necesaria
            RAISE e_param_error;
         END IF;
      END IF;

      vsproces := psproces;
      vcempres := pcempres;
      vcramo := pcramo;
      vsproduc := psproduc;
      vcagente := pcagente;
      vnpoliza := pnpoliza;
      vncertif := pncertif;
      vfhasta := pfhasta;

      -- campos que deben estar informados en funcion del valor de pngenerar
      IF pngenerar = 0 THEN
         -- el sproces no debe estar informado ya que queremos que se generen las cartas
         vsproces := NULL;
      ELSIF pngenerar = 1 THEN
         -- solo debe estar informado el sprcoes
         --vcempres := NULL; -- Bug 15289 - APD - 19/01/2011 - la empresa sí que es necesaria
         vcramo := NULL;
         vsproduc := NULL;
         vcagente := NULL;
         vnpoliza := NULL;
         vncertif := NULL;
         vfhasta := NULL;
      END IF;

      numerr := pac_md_fe_vida.f_generar_fe_vida(vsproces, vcempres, vcramo, vsproduc,
                                                 vcagente, vnpoliza, vncertif, vfhasta,
                                                 pngenerar, sproces, pnomfich, vtimp, mensajes);
      vpasexec := 2;

      IF numerr <> 0 THEN
         RETURN 1;
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
   END f_generar_fe_vida;

/*******************************************************************************
   FUNCION  F_GET_CONSULTA_FE_VIDA
   -función que devolverá un REF CURSOR con las pólizas que tienen un apunte en la Agenda de tipo 31
   -Llamará a la función PAC_MD_FE_DE_VIDA.F_GET_CONSULTA_FE_VIDA
   Parámetros:
    Entrada :
    1.   pcidioma. Identificador del idioma.
    2.   pcempres. Identificador de la empresa. Obligatorio.
    3.   psproduc. Identificador del producto.
    4.   pfinicial. Fecha inicio.
    5.   pffinal. Fecha final
    6.   pcramo. Identificador del ramo.
    7.   pcagente. Identificador del agente.
    8.   pcagrpro. Identificador de la agrupación de la póliza.

    Salida :
      Mensajes T_IAX_MENSAJES

   Retorna : REF CURSOR.
   ********************************************************************************/
   FUNCTION f_get_consulta_fe_vida(
      pcidioma IN NUMBER,
      pcempres IN NUMBER,
      psproduc IN NUMBER,
      pfinicial IN DATE,
      pffinal IN DATE,
      pcramo IN NUMBER,
      pcagente IN NUMBER,
      pcagrpro IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vobject        VARCHAR2(500) := 'PAC_IAX_FE_VIDA.F_GET_CONSULTA_FE_VIDA';
      vparam         VARCHAR2(4000)
         := 'pcidioma=' || pcidioma || ' pcempres=' || pcempres || ' psproduc=' || psproduc
            || ' pfinicial=' || pfinicial || ' pffinal=' || pffinal || ' pcramo=' || pcramo
            || ' pcagente= ' || pcagente || ' pcagrpro=' || pcagrpro;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vquery         VARCHAR2(4000);
      cur            sys_refcursor;
   BEGIN
         /*
         Nueva función que devuelve las pólizas que tienen un apunte en la Agenda de tipo 31.-Envío de Cartas de Fe de vida que cumplan con los filtros seleccionados.  Dichas pólizas deben cumplir los siguientes requisitos:

      "  Pólizas vigentes y no retenidas por siniestro o rescate.
      "  Se debe de haber enviado anteriormente la carta de fe de vida (existe un apunte en la Agenda de tipo Envío Carta Fe de Vida).

         */
      IF pcempres IS NULL
         OR pfinicial IS NULL
         OR pffinal IS NULL THEN
         RAISE e_param_error;
      END IF;

      cur := pac_md_fe_vida.f_get_consulta_fe_vida(pcidioma, pcempres, psproduc, pfinicial,
                                                   pffinal, pcramo, pcagente, pcagrpro,
                                                   mensajes);
      vpasexec := 2;
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_consulta_fe_vida;

   /*******************************************************************************
     FUNCION   F_GET_RENTAS_BLOQUEADAS
     -función que devuelve las pólizas con rentas bloqueadas debido a que no se ha certificado todavía la fe de vida de los titulares del contrat
     -Llamará a la función PAC_MD_FE_VIDA.F_GET_RENTAS_BLOQUEADAS
     Parámetros:
      Entrada :

          1.  pcidioma. Identificador del idioma.
          2.  pcempres. Identificador de la empresa. Obligatorio.
          3.  psproduc. Identificador del producto.
          4.  pfinicial. Fecha inicio.
          5.  pffinal. Fecha final
          6.  pcramo. Identificador del ramo.
          7.  pcagente. Identificador del agente.
          8.  pcagrpro. Identificador de la agrupación de la póliza.

      Salida :
        Mensajes T_IAX_MENSAJES

     Retorna : REF CURSOR.
     ********************************************************************************/
   FUNCTION f_get_rentas_bloqueadas(
      pcidioma IN NUMBER,
      pcempres IN NUMBER,
      psproduc IN NUMBER,
      pfinicial IN DATE,
      pffinal IN DATE,
      pcramo IN NUMBER,
      pcagente IN NUMBER,
      pcagrpro IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vobject        VARCHAR2(500) := 'PAC_IAX_FE_VIDA.F_GET_RENTAS_BLOQUEADAS ';
      vparam         VARCHAR2(4000)
         := 'pcidioma=' || pcidioma || ' pcempres=' || pcempres || ' psproduc=' || psproduc
            || ' pfinicial=' || pfinicial || ' pffinal=' || pffinal || ' pcramo=' || pcramo
            || ' pcagente= ' || pcagente || ' pcagrpro=' || pcagrpro;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vquery         VARCHAR2(4000);
      cur            sys_refcursor;
   BEGIN
         /*
         debe cumplir
      "  Pólizas vigentes y no retenidas por siniestro o rescate.
      "  Se debe de haber enviado anteriormente la carta de fe de vida (existe un apunte en la Agenda de tipo Envío Carta Fe de Vida en estado Pendiente).
      "  La póliza está bloqueada (pagosrenta.cblopag = 5.-Bloqueada)

         */
      IF pcempres IS NULL
         OR pfinicial IS NULL
         OR pffinal IS NULL THEN
         RAISE e_param_error;
      END IF;

      cur := pac_md_fe_vida.f_get_rentas_bloqueadas(pcidioma, pcempres, psproduc, pfinicial,
                                                    pffinal, pcramo, pcagente, pcagrpro,
                                                    mensajes);
      vpasexec := 2;
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_rentas_bloqueadas;

---------------------------------------
----------------------------------------
 /*******************************************************************************
  FUNCION  F_CONFIRMAR_FE_VIDA
  -función que se encargará de validar y confirmar la certificación de fe de vida de los titulares de una póliza
      y crea un apunte en la Agenda de dichas pólizas indicando que se ha enviado la carta.
  -Llamará a la función función PAC_MD_FE_DE_VIDA.F_CONFIRMAR_FE_VIDA.
  Parámetros:
   Entrada :

       1.  pnpoliza : number Número de póliza.
       2.  pncertif : number Número de certificado.
       3.  ptlista : sperson de los perceptores que han presentado su fe de vida
   Salida :
     Mensajes T_IAX_MENSAJES

  Retorna : number 0 ok, 1 error
  ********************************************************************************/
   FUNCTION f_confirmar_fe_vida(
      pnpoliza IN NUMBER,
      pncertif IN NUMBER,
      ptlista IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      numerr         NUMBER := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(4000)
             := ' pnpoliza=' || pnpoliza || ';pncertif=' || pncertif || ';ptlista=' || ptlista;
      vobject        VARCHAR2(200) := 'PAC_IAX_FE_VIDA.F_CONFIRMAR_FE_VIDA';
   BEGIN
      numerr := pac_md_fe_vida.f_confirmar_fe_vida(pnpoliza, pncertif, ptlista, mensajes);
      vpasexec := 2;

      IF numerr <> 0 THEN
         RETURN 1;
      END IF;

      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 111313);   -- Proceso Correcto.
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
   END f_confirmar_fe_vida;
END pac_iax_fe_vida;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_FE_VIDA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_FE_VIDA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_FE_VIDA" TO "PROGRAMADORESCSI";
