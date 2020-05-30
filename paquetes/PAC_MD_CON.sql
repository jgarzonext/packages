CREATE OR REPLACE PACKAGE pac_md_con IS
   /******************************************************************************
    NOMBRE:      PAC_MD_CON
    PROPÓSITO:   Funciones para las interfases en segunda capa
    REVISIONES:
    Ver        Fecha        Autor             Descripción
    ---------  ----------  ---------------  ------------------------------------
    1.0        ??/??/????   ???               1. Creación del package.
    2.0        07/05/2009   DRA               2. 0009981: IAX - Baixar l'empresa a totes les taules del model CFG
    3.0        17/12/2009   JAS               3. 0011302: CEM002 - Interface Libretas
    4.0        16/02/2010   ICV               4. 0012555: CEM002 - Interficie per apertura de llibretes
    6.0        26/08/2010   SRA               6. 14365: CRT002 - Gestion de personas
    7.0        01/09/2010   FAL               7. 14365: CRT002 - Gestion de personas
    8.0        22/11/2010   JAS               8. 13266: Modificación interfases apertura y cierre de puesto (parte PL) Diverses modificacions al codi
    9.0        13/09/2011   DRA               9. 0018682: AGM102 - Producto SobrePrecio- Definición y Parametrización
    10.0       28/02/2012   DRA               10. 0021467: AGM- Quitar en la descripción de riesgos el plan y al final se muestran caracteres raros
    11.0       10/04/2012   JMF               0021190 CRE998-CRE - Sistema de comunicaci Axis - eCredit (ver 0021187)
    12.0       09/10/2012   XVM               11. 0023687: Release 2. Webservices de Mutua de Propietarios
    13.0       27/12/2012   MAL               13. 0025129: RSA002 - Interafz WS cliente paridad peso-dolar
    14.0       18/07/2019   Shakti            14. IAXIS-4753: Ajuste campos Servicio I003
    15.0       01/08/2019   Shakti            15. IAXIS-4944
   ******************************************************************************/
   TYPE t_cambiomoneda IS RECORD(
      cmonedaorigen  eco_tipocambio.cmonori%TYPE,
      cmonedadestino eco_tipocambio.cmondes%TYPE,
      fcambio        eco_tipocambio.fcambio%TYPE,
      valor          eco_tipocambio.itasa%TYPE
   );

   TYPE tab_cambiomoneda IS TABLE OF t_cambiomoneda
      INDEX BY BINARY_INTEGER;

   TYPE tresp_sian IS RECORD(
      respok         VARCHAR2(5),
      respdesc       VARCHAR2(400)
   );

   TYPE tab_resp_sian IS TABLE OF tresp_sian
      INDEX BY BINARY_INTEGER;

   --Funcion que valida un usuario
   FUNCTION f_validar_usuario(
      pusuario IN VARCHAR2,
      ppassword IN VARCHAR2,
      pvalidado OUT NUMBER,
      poficina OUT NUMBER,
      ptnombre OUT VARCHAR2,
      psinterf IN OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_busqueda_persona(
      psip IN VARCHAR2,
      pctipdoc IN NUMBER,
      ptdocidentif IN VARCHAR2,
      ptnombre IN VARCHAR2,
      psinterf IN OUT NUMBER,
      mensajes IN OUT t_iax_mensajes,
      pcognom1 IN VARCHAR2 DEFAULT NULL,
      pcognom2 IN VARCHAR2 DEFAULT NULL,
      po_masdatos OUT NUMBER)
      RETURN NUMBER;

   FUNCTION f_busqueda_masdatos(
      psinterf IN OUT NUMBER,
      mensajes OUT t_iax_mensajes,
      po_masdatos OUT NUMBER)
      RETURN NUMBER;

   FUNCTION f_datos_persona(
      psip IN VARCHAR2,
      pcagente OUT NUMBER,
      psinterf IN OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_cuentas_persona(
      psperson IN VARCHAR2,
      pcrol IN NUMBER,
      pcestado IN NUMBER,
      pcsaldo IN NUMBER,
      porigen IN VARCHAR2,
      psinterf IN OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_cobro_recibo(
      pnrecibo IN NUMBER,
      pcobrado OUT NUMBER,
      psinterf IN OUT NUMBER,
      pterror OUT VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_abrir_puesto(
      pusuario IN VARCHAR2,
      ppassword IN VARCHAR2,
      psinterf IN OUT NUMBER,
      poficina OUT NUMBER,
      ptermlog OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_cerrar_puesto(
      pusuario IN VARCHAR2,
      psinterf IN OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   -- Bug 21458/108087 - 23/02/2012 - AMC
   -- Se añaden nuevos parametros de entrada
   FUNCTION f_convertir_documento(
      ptipoorigen IN VARCHAR2,
      ptipodestino IN VARCHAR2,
      pficheroorigen IN VARCHAR2,
      pficherodestino IN VARCHAR2,
      pplantillaorigen IN VARCHAR2,
      psinterf IN OUT NUMBER,
      pfirmadigital IN VARCHAR2,
      pfirmadigitalalias IN VARCHAR2,
      pfirmaelectronicacliente IN VARCHAR2,
      pfirmaelectronicaclienteimagen IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_obtener_valor_axis(pemp IN VARCHAR2, pcampo IN VARCHAR2, pvalemp IN VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION f_obtener_valor_emp(pemp IN VARCHAR2, pcampo IN VARCHAR2, pvalaxis IN VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION f_proceso_alta(
      pempresa IN NUMBER,
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pop IN VARCHAR2,
      pusuario IN VARCHAR2,
      psinterf IN OUT NUMBER,
      perror OUT VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_lista_polizas(
      pcempres IN NUMBER,
      psnip IN VARCHAR2,
      pcsituac IN NUMBER,
      psinterf OUT NUMBER,
      pcurlistapolizas OUT sys_refcursor,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_extracto_polizas(
      pcempres IN NUMBER,
      pnpoliza IN NUMBER,
      pfini IN DATE,
      pffin IN DATE,
      psinterf OUT NUMBER,
      pcurextractopol OUT sys_refcursor,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   -- Bug 0021190 - 10/04/2012 - JMF
   FUNCTION f_extracto_polizas_asegurado(
      pcempres IN NUMBER,
      pnpoliza IN NUMBER,
      pfini IN DATE,
      pffin IN DATE,
      psinterf OUT NUMBER,
      pcurextractopol OUT sys_refcursor,
      mensajes IN OUT t_iax_mensajes,
      psnip IN VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_detalle_poliza(
      pnpoliza IN NUMBER,
      psinterf OUT NUMBER,
      pcurdetpol OUT sys_refcursor,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   -- Bug 0021190 - 10/04/2012 - JMF
   FUNCTION f_detalle_poliza_asegurado(
      pnpoliza IN NUMBER,
      psinterf OUT NUMBER,
      pcurdetpol OUT sys_refcursor,
      mensajes IN OUT t_iax_mensajes,
      psnip IN VARCHAR2)
      RETURN NUMBER;

   /*************************************************************************
                     Impresió llibreta d'estalvi
      param in  pcempres:       codi d'empresa
      param in  psseguro:       sseguro de la pòlissa
      param in  pnpoliza:       npoliza de la pòlissa
      param in  pncertif:       ncertif de la pòlissa
      param in  pnpolcia:       número de pòlissa de la companyia
      param in  pvalsaldo:      flag per indicar si cal realitzar validació de saldo
      param in  pisaldo:        saldo del moviment de llibreta a partir del qual se vol imprimir (per validacions).
      param in  pcopcion:       opció d'impressió
                                    1 -> Actualització de registres pendents
                                    2 -> Reimpressió a partir de número de seqüència
      param in  pnseq:          número de seqüència a partir del qual realitzar la reimpressió (opció d'impressió 2)
      param in  pfrimpresio     Data a partir del qual realitzar la reimpressió (opció d'impressió 2)
      param in  pnmov           número de moviments a retornar (-1 vol dir tots)
      param in  porden          ordenació de la llibreta
      param in  pcidioma        idioma de les descripcions de moviments de llibreta
      param out pcur_reg_lib    cursor/llista de moviments de llibreta impressos
      param in out  mensajes    missatges d'error
      return                    0/1 -> Tot OK/error
   *************************************************************************/
   FUNCTION f_imprimir_libreta(
      pcempres IN NUMBER,
      psseguro IN NUMBER,
      pnpoliza IN NUMBER,
      pncertif IN NUMBER,
      pnpolcia IN VARCHAR2,
      pvalsaldo IN NUMBER,
      pisaldo IN NUMBER,
      pcopcion IN NUMBER,
      pnseq IN NUMBER,
      pfrimpresio IN DATE,
      pnmov IN NUMBER,
      porden IN NUMBER,
      pcidioma IN NUMBER,
      pcur_reg_lib OUT sys_refcursor,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_listado_doc(
      psip IN VARCHAR2,
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      psinterf IN OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_get_detalle_doc(
      pid IN VARCHAR2,
      pdestino IN OUT VARCHAR2,
      pnombre IN VARCHAR2,
      psinterf IN OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_datoscontratos(
      psperson IN VARCHAR2,
      porigen IN VARCHAR2,
      psinterf IN OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   --Ini Bug.: 0012555 - ICV - 16/02/2010 - CEM002 - Interficie per apertura de llibretes
   FUNCTION f_imprimir_portada_libreta(
      pcempres IN NUMBER,
      psseguro IN NUMBER,
      pnpoliza IN NUMBER,
      pncertif IN NUMBER,
      pnpolcia IN VARCHAR2,
      ptproducto IN OUT VARCHAR2,
      pnnumide IN OUT VARCHAR2,
      ptnombre IN OUT VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   --Fin Bug.: 0012555

   -- Bug 14365 - 01/09/2010 - FAL - Alta de personas en el C.I
   FUNCTION f_alta_persona(
      psip IN VARCHAR2,
      pcagente OUT NUMBER,
      psinterf IN OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   -- Fi Bug 14365 - 01/09/2010 - FAL

   -- Bug 14365 - 26/08/2010 - SRA - función que devuelve un cursor con todas las equivalencias entre códigos origen de la empresa
   -- y su código equivalente en AXIS
   FUNCTION f_obtener_valores_axis(
      pemp IN VARCHAR2,
      pcampo IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   -- Bug 14365 - 26/08/2010 - SRA - función que devuelve un cursor con todas las equivalencias entre códigos origen en AXIS
   -- y su código equivalente en la empresa
   FUNCTION f_obtener_valores_emp(
      pemp IN VARCHAR2,
      pcampo IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   -- BUG21467:DRA:01/03/2012:Inici
   FUNCTION f_get_datos_host(
      pcempres IN NUMBER,
      datpol IN ob_iax_int_datos_poliza,
      pregpol IN t_iax_int_preg_poliza,
      psinterf IN OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   -- BUG21467:DRA:01/03/2012:Fi
   FUNCTION f_cobrar_recibo(
      pnrecibo IN NUMBER,
      pctipcob IN NUMBER,
      --pnreccaj IN NUMBER DEFAULT NULL, -- INI -IAXIS-4153 - JLTS - 05/06/2019 nuevo parámetro      
      pnreccaj IN VARCHAR2 DEFAULT NULL, /* Cambios de IAXIS-4753 */
      pcmreca IN NUMBER DEFAULT NULL, -- INI -IAXIS-4153 - JLTS - 05/06/2019 nuevo parámetro
      mensajes IN OUT t_iax_mensajes,
      PCINDICAF IN VARCHAR2 DEFAULT NULL ,------Changes for 4944
      PCSUCURSAL IN VARCHAR2 DEFAULT NULL ,------Changes for 4944
      PNDOCSAP IN VARCHAR2 DEFAULT NULL,------Changes for 4944
      pcususap IN VARCHAR2 DEFAULT NULL )------Changes for 4944 
      RETURN NUMBER;

   FUNCTION f_insert_cuota(
      pctapres IN VARCHAR2,
      pidpago IN NUMBER,
      pfpago IN DATE,
      picapital IN NUMBER,
      pfalta IN DATE,
      pcmoneda IN NUMBER,
      pcempres IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_importe_financiacion_pdte(
      pcempres IN NUMBER,
      psseguro IN NUMBER,
      pimporte OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   -- Ini Bug 23687 - XVM - 09/10/2012
   /*************************************************************************
                  Función f_recordarpwd: su finalidad es enviar un correo al usuario
      a la dirección pasada por parámetro notificándole su password de acceso a la aplicación
      param in  pcempres:       Código de empresa
      param in  pcidioma:       Código de idioma
      param in  pcusuari:       Código de usuario
      param in  pto:            Dirección de correo a enviar (sería el "Para:" del correo)
      param out mensajes        Mensajes de error
      return                    0/1 -> Todo OK/error
   *************************************************************************/
   FUNCTION f_recordarpwd(
      pcempres IN NUMBER,
      pcidioma IN NUMBER,
      pcusuari IN VARCHAR2,
      pto IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
                  Función f_csinotesws: función para mover un fichero de la ubicaicón de
      gedox temporal a GEDOX
      param in  pcempres:         Código de empresa
      param in  ptfilename:       Nombre del fichero sin path y con extensión
      param in  pcategoria:       Categoría del fichero
      param in  pcdesc:           Descripción del fichero a mover
      param in  pidref:           Identificador del objeto asociado al fichero
      param in  pcagente:         Agente por defecto
      param out mensajes          Mensajes de error
      return                      0/nºerr -> Todo OK/Código de error
   *************************************************************************/
   FUNCTION f_csinotesws(
      pcempres IN NUMBER,
      ptfilename IN VARCHAR2,
      pcategoria IN NUMBER,
      pcdesc IN VARCHAR2,
      pidref IN NUMBER,
      pcagente IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   -- Fin Bug 23687 - XVM - 09/10/2012
   -- Ini Bug 25129/132934 - MAL - 27/12/2012
   /*************************************************************************
                  Función  f_obtener_cambio_moneda: Funcion para obtener el tipo de
      cambio de una moneda
      param in  pcempres:         Código de empresa
      param in  cmoneda_origen:   Codigo de la moneda que quiere convertirse
      param in  cmoneda_destino:  Codigo de la moneda que a la cual desea convertirse
      param in  fcambio:          Fecha de la tasa de cambio
      param in  cambio_desde:     0/1 Indicador para obtener el tipo de cambio
                                  de varias fechas anteriores a fcambio o una fecha  unica
      param out mensajes          Mensajes de error
      return                      0/nºerr -> Todo OK/Código de error
   *************************************************************************/
   FUNCTION f_obtener_cambio_moneda(
      pcempres IN NUMBER,
      pcmoneda_origen IN NUMBER,
      pcmoneda_destino IN NUMBER,
      pfcambio IN DATE,
      pcambio_desde IN BOOLEAN,
      mensajes IN OUT t_iax_mensajes,
      tvalcotiza OUT tab_cambiomoneda)
      RETURN NUMBER;

   -- fin Bug 25129/132934 - MAL - 27/12/2012

   -- Bug 024791 - 01/09/2010 - JLB -Nuevas interfaces de autos
   /*************************************************************************
                   Función  f_ultimoSeguroVehiculo: Funcion para obtener el tipo de cambio de una moneda
       param in  ptipomatricula:   Codigo de la moneda que quiere convertirse
       param in  pmatricula:  Codigo de la moneda que a la cual desea convertirse
       param out pfechaultimavig última vigencia
       paran out pcompani        compañia ultima vigencia
       param out mensajes          Mensajes de error
       return                      0 ok /nºerr -> Código de error
    *************************************************************************/
   FUNCTION f_ultimosegurovehiculo(
      ptipomatricula IN VARCHAR2,
      pmatricula IN VARCHAR2,
      pfechaultimavig OUT DATE,
      pcompani OUT NUMBER,
      psinterf IN OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
                   Función  f_antiguedadConductor: Funcion para obtener el tipo de cambio de una moneda
       param in  ptipodoc:  Tipo de documento
       param in  pnnumide:  Identificador de persona fisica
       param out pantiguedad: antiguedad
       param out pcompani:    compañia
       param out mensajes          Mensajes de error
       return                      0 ok /nºerr -> Código de error
    *************************************************************************/
   FUNCTION f_antiguedadconductor(
      ptipodoc IN VARCHAR2,
      pnnumide IN VARCHAR2,
      pantiguedad OUT NUMBER,
      pcompani OUT NUMBER,
      psinies OUT NUMBER,
      psinterf IN OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
       Función  f_solicitar_inspeccion: Funcion para pedir orden de inspección
         param in  psseguro:  Identificador de seguro
         param in  pnriesgo:  Identificador de riesgo
         param in  pnmovimi:  Identificador de movimiento
         param out ptabla:  Tablas sobre la que obtener datos 'EST' o Relase
         param out pnordenext:   Nº identificador de orden de petición
         param out psinterf:    codigo secuencial de interfaz
         param out mensajes            Mensajes de error
         return                      0 ok /nºerr -> Código de error
      *************************************************************************/
   FUNCTION f_solicitar_inspeccion(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      pmotinspec IN NUMBER,
      ptabla IN VARCHAR2,
      pnordenext OUT NUMBER,
      psinterf IN OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   --BUG 29177/160128:NSS:16-12-2013
   FUNCTION f_lista_contratos_pago(
      pipago IN NUMBER,
      psperson IN NUMBER,
      pnsinies IN VARCHAR2,
      psseguro IN NUMBER,
      psinterf OUT NUMBER,
      pcontratos OUT t_iax_sin_trami_pago_ctr,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_resultado_carga(
      pcempres IN NUMBER,
      psproces IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   -- Inici Bug24918 MMS 20140424
   k_cinterfsian CONSTANT int_hostb2b.cinterf%TYPE := 'I042';

   FUNCTION f_export_datos_sian(
      pcempres IN NUMBER,
      ppath_in IN VARCHAR2,
      ppath_out IN VARCHAR2,
      pfich IN VARCHAR2,
      pproduc IN NUMBER,
      mensajes IN OUT t_iax_mensajes,
      trespuesta OUT tab_resp_sian)
      RETURN NUMBER;
-- Fin Bug24918 MMS 20140424
END pac_md_con;
/
