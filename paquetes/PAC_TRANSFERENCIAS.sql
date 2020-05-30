--------------------------------------------------------
--  DDL for Package PAC_TRANSFERENCIAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_TRANSFERENCIAS" AUTHID CURRENT_USER AS
/******************************************************************************
   NOM:       PAC_TRANSFERENCIAS

   REVISIONS:
   Ver        Fecha       Autor  Descripción
   ---------  ----------  -----  ------------------------------------
   1.0        23/06/2009  XPL    0010317: IAX - Análisis de transferencias
   2.0        04/02/2010  DRA    0012913: CRE200 - Mejoras en Transferencias
   3.0        29/04/2010  ICV    0013830: APR707 - Adaptación de las transferencias
   4.0        05/05/2010  DRA    0014344: APRA - Incorporar a transferencias los pagos de liquidación de comisiones
   33.0       21/04/2015  YDA   33. 33886/202377: Se modifica la fun. f_get_transferencias para incluir en la consulta la tabla pagoctacliente
   34.0       21/04/2015  YDA   34. 33886/202377: Se modifica la fun. f_insert_remesas_previo para inlcuir el manejo del pago de cta de cliente
   35.0       21/04/2015  YDA   35. 33886/202377: Se modifica la fun. f_transferir para manejar la actualización en la pagoctacliente
   36.0       14/01/2015   MDS  36. 0039238/0223588: Liquidación de comisiones según nivel de red comercial (bug hermano interno)
******************************************************************************//*
   /*
   Funcion que se encarga de tratar todos los casos seleccionados en la tabla remesas,
   actualizado estado de recibos a tranferidos....
   */
   FUNCTION f_transferir(
      pcempres IN NUMBER,
      pfabono IN DATE,   -- BUG12913:DRA:04/02/2010
      pnremesa OUT NUMBER)
      RETURN NUMBER;

   FUNCTION f_generacion_fichero(pnremesa IN NUMBER, pfabono IN DATE)
      -- BUG12913:DRA:04/02/2010
   RETURN NUMBER;

-- Bug 0039238/0223588 - MDS - 14/01/2016
-- reutilizar el primer parámetro de la función
-- de psremesa IN NUMBER
-- a  pccc     IN VARCHAR2
   FUNCTION f_set_remesas_sepa(pccc IN VARCHAR2, pnremesa IN NUMBER, pfabono IN DATE)
      RETURN NUMBER;

   FUNCTION f_generacion_fichero_iban(pnremesa IN NUMBER, pfabono IN DATE)
      -- BUG12913:DRA:04/02/2010
   RETURN NUMBER;

   /* funcion que genera el fichero para una remesa específica*/
   FUNCTION f_generar_fichero(pnremesa IN NUMBER, pfabono IN DATE)
      -- BUG12913:DRA:04/02/2010
   RETURN NUMBER;

   /* JRH 11/2007 funcion que inserta en ctaseguro para rentas*/
   FUNCTION insertar_ctaseguro(
      psseguro IN NUMBER,
      pfefecto IN DATE,
      pnnumlin IN NUMBER,
      pffecmov IN DATE,
      pffvalmov IN DATE,
      pcmovimi IN NUMBER,
      pimovimi IN NUMBER,
      pimovimi2 IN NUMBER,
      pnrecibo IN NUMBER,
      pccalint IN NUMBER,
      pcmovanu IN NUMBER,
      pnsinies IN NUMBER,
      psmovrec IN NUMBER,
      pcfeccob IN NUMBER,
      --vienen de fmovcta
      pfmovini IN DATE,
      pfmovdia IN DATE DEFAULT NULL,
      psrecren IN NUMBER DEFAULT NULL   --JRH Id pago de renta
                                     )
      RETURN NUMBER;

   -- BUG10604:DRA:02/07/2009:Inici
    /*************************************************************************
     FUNCTION f_act_reembacto
     Actualitza els reembolsos marcant-los com transferits
     param in p_nreemb    : código del reembolso
     return             : NUMBER
    *************************************************************************/
   FUNCTION f_act_reembacto(
      p_nreemb IN NUMBER,
      p_sremesa IN NUMBER,
      p_ftrans IN DATE,
      p_nfact IN NUMBER,
      p_nlinea IN NUMBER,
      p_ctipo IN NUMBER)
      RETURN NUMBER;

/***********************************************************************
      Limpia de la tabla remesas_previo los registros de un usuario
      param out mensajes : mensajes de error
      return             : 0 OK, 1 Error
   ***********************************************************************/
   FUNCTION f_limpia_remesasprevio
      RETURN NUMBER;

   /***********************************************************************
      Función que nos dice si tenemos registros pendientes de gestionar por un usuario(f_user)
      en el caso que haya registros para gestionar devolveremos en el param phayregistros un 1,
      en el caso contrario phayregistros =  0
      param out mensajes : mensajes de error
      param out hayregistros : 0 no hay registros, N num. registros
      return             : 0 OK , 1 error
   ***********************************************************************/
   FUNCTION f_registros_pendientes(phayregistros OUT NUMBER)
      RETURN NUMBER;

/***********************************************************************
      Función que nos dice si tenemos registros en las tablas que ya esten intentando transferir
      otros usuarios, en este caso devolveremos una notificación y no dejaremos seguir. Ya que los registros
      ya estaran siendo modificados.
      param in  ptipobusqueda : varchar2, tots els tipus que hem marcat per fer la cerca
      param out hayregistros : 0 no hay registros, 1 hay registros
      return             : 0 OK , 1 error
   ***********************************************************************/
   FUNCTION f_registros_duplicados(ptipobusqueda IN VARCHAR2, phayregistros OUT NUMBER)
      RETURN NUMBER;

/***********************************************************************
      Función que nos dice si tenemos registros en las tablas que ya esten intentando transferir
      otros usuarios, en este caso devolveremos una notificación y no dejaremos seguir. Ya que los registros
      ya estaran siendo modificados.
      param in  ptipobusqueda : varchar2, tots els tipus que hem marcat per fer la cerca
      param int ptipo : 1 Rentas, 2 Recibos, 3 Siniestros y 4 Reembolsos
      return             : true ENCONRADO , False
   ***********************************************************************/
   FUNCTION f_istipobusqueda(ptipobusqueda IN VARCHAR2, ptipo IN VARCHAR2)
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
      pcidioma IN NUMBER,
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
      --1- Rentas 2- recibos 3- siniestros 4-Reembolsos
      piimportt IN NUMBER,
      psperson IN NUMBER,
      pprocesolin OUT NUMBER)
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
      pnremesa IN NUMBER,
      pccc IN VARCHAR2,
      pidioma IN NUMBER,
      psquery OUT VARCHAR2)
      RETURN NUMBER;

   /***********************************************************************
      Función que nos actualiza la tabla, si le pasamos un sremesa actualiza solo
      el registro con marcado, si no le pasamos el sremesa se marcan o desmarcan todos
      return             : 0 OK , 1 error
   ***********************************************************************/
   FUNCTION f_actualiza_remesas_previo(psremesa IN NUMBER, pcmarcado IN NUMBER)
      RETURN NUMBER;

    /***********************************************************************
      Función que nos devuelve el total de los registros marcados en remesas_previo
      return             : 0 OK , 1 error
   ***********************************************************************/
   FUNCTION f_get_total(pnremesa IN NUMBER, pccc IN VARCHAR2, ptotal OUT NUMBER)
      RETURN NUMBER;

    /***********************************************************************
      Función que nos devuelve las descripciones de los bancos
      return             : 0 OK , 1 error
   ***********************************************************************/
   FUNCTION f_get_cuentas(pnremesa IN NUMBER, pccc IN VARCHAR2, vsquery OUT VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_cuenramo(pccobban IN NUMBER, psproduc IN NUMBER)
      RETURN NUMBER;

    /***********************************************************************
      Función que nos devuelve la cuenta de cargo, el producto, el tipo de banco y el ccobban
      return             : 0 OK , 1 error
   ***********************************************************************/
   FUNCTION f_get_ctacargo(
      pcempres IN NUMBER,   -- BUG14344:DRA:05/05/2010
      psseguro IN NUMBER,
      pcconcep IN NUMBER,
      p_ccc_abono IN VARCHAR2,   -- BUG11396:DRA:14/01/2010
      p_ctipban_abono IN NUMBER,   -- BUG11396:DRA:14/01/2010
      w_producto OUT NUMBER,
      w_cuenta OUT VARCHAR2,
      w_ctipban OUT VARCHAR2,
      v_ccobban OUT NUMBER)
      RETURN NUMBER;

   -- BUG12913:DRA:04/02/2010:Inici
   /*************************************************************************
         Función que valida que la fecha de abono para las transferencias sea correcta
         param in fabono    : fecha de abono
         return             : 0 la validación ha sido correcta
                              1 la validación no ha sido correcta
   *************************************************************************/
   FUNCTION f_valida_fabono(pfabono IN DATE, pterror OUT VARCHAR2)
      RETURN NUMBER;

   /***********************************************************************
      Función que genera de nuevo el fichero excel
      -- Bug 0032079 - JMF - 15/07/2014
      pprevio             : 1 = Listado previo, resto valores listado normal
      return             : 0 OK , 1 error
   ***********************************************************************/
   FUNCTION f_generar_fichero_excel(params_out OUT VARCHAR2, pprevio IN NUMBER DEFAULT NULL)
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
   FUNCTION f_get_dias_abono(pcempres IN NUMBER, pnumdias OUT NUMBER)
      RETURN NUMBER;

-- BUG12913:DRA:22/03/2010:Fi

   --Bug.: 13830 - ICV - 27/04/2010
   FUNCTION f_generacion_fichero_apra(pnremesa IN NUMBER, pfabono IN DATE)
      RETURN NUMBER;

   -- BUG14344:DRA:17/05/2010:Inici
   /***********************************************************************
      Función que el texto a mostrar en la columna de origen

      param in ptipproceso IN VARCHAR2,   --1- Rentas 2- recibos 3- siniestros 4-Reembolsos
      param out tliteral   OUT VARCHAR2
   ***********************************************************************/
   FUNCTION f_get_desc_concepto(
      ptipproceso IN VARCHAR2,
      pcidioma IN NUMBER,
      ptlitera OUT VARCHAR2)
      RETURN NUMBER;

-- BUG14344:DRA:17/05/2010:Fi

   --Bug.: 15118 - JRB - 21/06/2010
   FUNCTION f_generacion_fichero_ensa(pnremesa IN NUMBER, params_out OUT VARCHAR2)
      RETURN NUMBER;

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
      pnremesa IN NUMBER,
      pidioma IN NUMBER,
      psquery OUT VARCHAR2)
      RETURN NUMBER;

   /***********************************************************************
      --BUG19522 - JTS - 10/11/2011
      Función que actualiza la fecha de cambio
      return             : 0 OK , 1 error
   ***********************************************************************/
   FUNCTION f_set_fcambio(psremesa IN NUMBER, pfcambio IN DATE)
      RETURN NUMBER;

   FUNCTION f_get_ident_interv(
      pnif IN VARCHAR2,
      psufix IN VARCHAR2,
      pidpais IN VARCHAR2,
      pidinterv OUT VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_get_trans_retenida(pcagente IN NUMBER, psquery OUT VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_trans_ret_cancela(psclave IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_trans_ret_desbloquea(psclave IN NUMBER)
      RETURN NUMBER;

-- Bug 0039238/0223588 - MDS - 14/01/2016
   FUNCTION f_generacion_ficheros_sepa(pnremesa IN NUMBER, pfabono IN DATE)
      RETURN NUMBER;
-- Bug 0041159 - MCA - 30/03/2016
   FUNCTION f_destinatario_pago(psremesa IN NUMBER, patribu IN NUMBER)
      RETURN VARCHAR2;

END pac_transferencias;

/

  GRANT EXECUTE ON "AXIS"."PAC_TRANSFERENCIAS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_TRANSFERENCIAS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_TRANSFERENCIAS" TO "PROGRAMADORESCSI";
