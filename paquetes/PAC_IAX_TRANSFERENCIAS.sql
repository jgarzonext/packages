--------------------------------------------------------
--  DDL for Package PAC_IAX_TRANSFERENCIAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_IAX_TRANSFERENCIAS" AS
/******************************************************************************
   NOMBRE:       pac_iax_transferencias
   PROPÓSITO:  Gestión de las transferencias

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        23/06/2009   XPL                1. Creación del package.
   2.0        04/02/2010   DRA                2. 0012913: CRE200 - Mejoras en Transferencias
   3.0        17/05/2010   DRA                3. 0014344: APRA - Incorporar a transferencias los pagos de liquidación de comisiones
******************************************************************************/
/***********************************************************************
      Limpia de la tabla remesas_previo los registros de un usuario
      param out mensajes : mensajes de error
      return             : 0 OK, 1 Error
   ***********************************************************************/
   FUNCTION f_limpia_remesasprevio(mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

/***********************************************************************
      Función que nos dice si tenemos registros pendientes de gestionar por un usuario(f_user)
      en el caso que haya registros para gestionar devolveremos en el param phayregistros un 1,
      en el caso contrario phayregistros =  0
      param out mensajes : mensajes de error
      param out hayregistros : 0 no hay registros, N num. registros
      return             : 0 OK , 1 error
   ***********************************************************************/
   FUNCTION f_registros_pendientes(phayregistros OUT NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

/***********************************************************************
      Función que nos dice si tenemos registros en las tablas que ya esten intentando transferir
      otros usuarios, en este caso devolveremos una notificación y no dejaremos seguir. Ya que los registros
      ya estaran siendo modificados.
      param in  ptipobusqueda : varchar2, tots els tipus que hem marcat per fer la cerca
      param out mensajes : mensajes de error
      param out hayregistros : 0 no hay registros, 1 hay registros
      return             : 0 OK , 1 error
   ***********************************************************************/
   FUNCTION f_registros_duplicados(
      ptipobusqueda IN VARCHAR2,
      phayregistros OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

    /***********************************************************************
      Función que nos inserta en la tabla remesas_previo los registros que estamos buscando.
      param in  pcempres
      param in  pcidioma IN NUMBER,
      param in  psremisesion IN NUMBER,   -- Identificador de la sesion de inserciones de la remesa
      param in  ptipproceso IN VARCHAR2,   --1- Rentas 2- recibos 3- siniestros 4-Reembolsos
      param in  pcramo IN NUMBER,
      param in  psproduc IN NUMBER,
      param in  pfabono IN DATE,
      param in  pftransini IN DATE,
      param in  pftransfin IN DATE,
      param in  pctransferidos IN NUMBER,
      param in  pprestacion IN NUMBER DEFAULT 0,
      param in  pagrup IN NUMBER DEFAULT NULL,   --Agrupación
      param in  pcausasin IN NUMBER DEFAULT NULL   --En el caso de siniestros, la causa del siniestro
      return             : 0 OK , 1 error
   ***********************************************************************/
   FUNCTION f_insert_remesas_previo(
      pcempres IN NUMBER,
      pagrupacion IN NUMBER,
      pcramo IN NUMBER,
      psproduc IN NUMBER,
      pfabonoini IN DATE,
      pfabonofin IN DATE,
      pftransini IN DATE,
      pftransfin IN DATE,
      pctransferidos IN NUMBER,
      pnremesa IN NUMBER,
      ptipproceso IN VARCHAR2,
      piimportt IN NUMBER,
      psperson IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

    /***********************************************************************
      Función que nos devuelve los registros de la tabla remesas_previo por usuario
      return             : 0 OK , 1 error
   ***********************************************************************/
   FUNCTION f_get_transferencias(
      pcempres IN NUMBER,
      pagrupacion IN NUMBER,
      pcramo IN NUMBER,
      psproduc IN NUMBER,
      pfabonoini IN DATE,
      pfabonofin IN DATE,
      pftransini IN DATE,
      pftransfin IN DATE,
      pctransferidos IN NUMBER,
      pctipobusqueda IN VARCHAR2,
      nremesa IN NUMBER,
      pccc IN VARCHAR2,
      pcurtransferencias OUT sys_refcursor,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

    /***********************************************************************
      Función que nos actualiza la tabla, si le pasamos un sremesa actualiza solo
      el registro con marcado, si no le pasamos el sremesa se marcan o desmarcan todos
      return             : 0 OK , 1 error
   ***********************************************************************/
   FUNCTION f_actualiza_remesas_previo(
      psremesa IN NUMBER,
      pcmarcado IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

    /***********************************************************************
      Función que nos devuelve el total de los registros marcados en remesas_previo
      return             : 0 OK , 1 error
   ***********************************************************************/
   FUNCTION f_get_total(
      pnremesa IN NUMBER,
      pccc IN VARCHAR2,
      ptotal OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

    /***********************************************************************
      Función que nos devuelve las descripciones de los bancos
      return             : 0 OK , 1 error
   ***********************************************************************/
   FUNCTION f_get_cuentas(
      pnremesa IN NUMBER,
      pccc IN VARCHAR2,
      pcurbancos OUT sys_refcursor,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

    /***********************************************************************
      Función que nos genera un fichero y nos devuelve la ruta y nombre del fichero
      return             : 0 OK , 1 error
   ***********************************************************************/
   FUNCTION f_generacion_fichero(
      pnremesa IN NUMBER,
      pfabono IN DATE,   -- BUG12913:DRA:04/02/2010
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

    /***********************************************************************
      Función que nos transfiere y nos graba los datos de remesas a remesas_previo
      return             : 0 OK , 1 error
   ***********************************************************************/
   FUNCTION f_transferir(
      pcempres IN NUMBER,
      pfabono IN DATE,   -- BUG12913:DRA:04/02/2010
      pnremesa OUT NUMBER,
      params_out OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   -- BUG12913:DRA:04/02/2010:Inici
   /*************************************************************************
         Función que valida que la fecha de abono para las transferencias sea correcta
         param in fabono    : fecha de abono
         param out mensajes : mensajes de error
         return             : 0 la validación ha sido correcta
                              1 la validación no ha sido correcta
   *************************************************************************/
   FUNCTION f_valida_fabono(pfabono IN DATE, mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   -- BUG12913:DRA:04/02/2010:Fi

   -- BUG12913:DRA:08/02/2010:Inici
   -- Bug 0032079 - JMF - 15/07/2014
   /***********************************************************************
      Función que genera de nuevo el fichero excel
      pprevio             : 1 = Listado previo, resto valores listado normal
      return             : 0 OK , 1 error
   ***********************************************************************/
   FUNCTION f_generar_fichero_excel(
      params_out OUT VARCHAR2,
      mensajes OUT t_iax_mensajes,
      pprevio IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

   -- BUG12913:DRA:08/02/2010:Fi

   -- BUG12913:DRA:22/03/2010:Inici
   /***********************************************************************
      Función que retorna el numero de dias de fecha de abono
      param in cempres   : codigo de empresa
      param out pnumdias : numero de dias
      param out mensajes : mensajes de error
      return             : 0 OK , 1 error
   ***********************************************************************/
   FUNCTION f_get_dias_abono(
      pcempres IN NUMBER,
      pnumdias OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

-- BUG12913:DRA:22/03/2010:Fi

   -- BUG14344:DRA:17/05/2010:Inici
   /***********************************************************************
      Función que el texto a mostrar en la columna de origen

      param in ptipproceso IN VARCHAR2,   --1- Rentas 2- recibos 3- siniestros 4-Reembolsos
      param out tliteral   OUT VARCHAR2
   ***********************************************************************/
   FUNCTION f_get_desc_concepto(
      ptipproceso IN VARCHAR2,
      ptlitera OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

-- BUG14344:DRA:17/05/2010:Fi

   /***********************************************************************
      --BUG19522 - JTS - 28/10/2011
      Función que nos devuelve los registros agrupados
      de la tabla remesas_previo por usuario
      return             : 0 OK , 1 error
   ***********************************************************************/
   FUNCTION f_get_transferencias_agrup(
      pcempres IN NUMBER,
      pagrupacion IN NUMBER,
      pcramo IN NUMBER,
      psproduc IN NUMBER,
      pfabonoini IN DATE,
      pfabonofin IN DATE,
      pftransini IN DATE,
      pftransfin IN DATE,
      pctransferidos IN NUMBER,
      pctipobusqueda IN VARCHAR2,
      nremesa IN NUMBER,
      pcurtransferencias OUT sys_refcursor,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
      --BUG19522 - JTS - 10/11/2011
      Función que actualiza la fecha de cambio
      return             : 0 OK , 1 error
   ***********************************************************************/
   FUNCTION f_set_fcambio(psremesa IN NUMBER, pfcambio IN DATE, mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_trans_retenida(
      pcagente IN NUMBER,
      pcurtransferencias OUT sys_refcursor,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_trans_ret_cancela(psclave IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_trans_ret_desbloquea(psclave IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER;
END pac_iax_transferencias;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_TRANSFERENCIAS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_TRANSFERENCIAS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_TRANSFERENCIAS" TO "PROGRAMADORESCSI";
