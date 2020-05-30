
CREATE OR REPLACE PACKAGE "PAC_CON" IS
   /******************************************************************************
      NOMBRE:      PAC_CON
      PROPÓSITO:   Preparación para conexiones con interfaces
      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
      1.1                                     1. Creación del package.
      1.2        02/09/2009  JMF              2. 0010875: CEM - Búsqueda de personas por NIF con letra minúscula
      2.         07/09/2009  NMM              3. 11948: CEM - Alta de destinatatios.
      6.0        26/08/2010  SRA              6. 14365: CRT002 - Gestion de personas
      7.0        01/09/2010  FAL              7. 14365: CRT002 - Gestion de personas
      8.0        22/11/2010  JAS              8. 13266: CIVF001 - Modificación interfases apertura y cierre de puesto (parte PL)
      9.0        17/02/2010  ETM              9. 0017389: ENSA103 - SAP - Modificacions procés pagaments
      10.0       13/09/2011  DRA              10. 0018682: AGM102 - Producto SobrePrecio- Definición y Parametrización
      11.0       08/02/2012  JMP              11. 21270/106644: LCOL898 - Interfase persones. Enviar segon registre amb el RUT
      12.0       01/03/2012  DRA              12. 0021467: AGM- Quitar en la descripción de riesgos el plan y al final se muestran caracteres raros
      13.0       10/04/2012  JMF              0021190 CRE998-CRE - Sistema de comunicaci Axis - eCredit (ver 0021187)
      14.0       09/10/2012  XVM              13. 0023687: Release 2. Webservices de Mutua de Propietarios
      15.0       04/06/2013  ETM              0026318: POSS038-(POSIN011)-Interfaces:IAXIS-SAP: Interfaz de Personas
      16.0       24/10/2013  JMG              16. 0028644-156855 : POS - PER - Reproceso de interfaz de personas.
   ******************************************************************************/
   --------------------------------------------------------------------------------------Funcion que valida un usuario
   FUNCTION f_validar_usuario(
      pempresa IN NUMBER,
      pusuario IN VARCHAR2,
      ppassword IN VARCHAR2,
      pvalidado OUT NUMBER,
      poficina OUT NUMBER,
      ptnombre OUT VARCHAR2,
      psinterf IN OUT NUMBER,
      perror OUT VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_busqueda_persona(
      pempresa IN NUMBER,
      psip IN VARCHAR2,
      pctipdoc IN NUMBER,
      ptdocidentif IN VARCHAR2,
      ptnombre IN VARCHAR2,
      pterminal IN VARCHAR2,
      pmasdatos IN NUMBER,
      pomasdatos OUT NUMBER,
      psinterf IN OUT NUMBER,
      perror OUT VARCHAR2,
      pcognom1 IN VARCHAR2 DEFAULT NULL,
      pcognom2 IN VARCHAR2 DEFAULT NULL,
      pusuario IN VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_datos_persona(
      pempresa IN NUMBER,
      psip IN VARCHAR2,
      pterminal IN VARCHAR2,
      psinterf IN OUT NUMBER,
      perror OUT VARCHAR2,
      pusuario IN VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_cuentas_persona(
      pempresa IN NUMBER,
      psperson IN VARCHAR2,
      pcrol IN NUMBER,
      pcestado IN NUMBER,
      pcsaldo IN NUMBER,
      pcoperador IN VARCHAR2,
      poficina IN VARCHAR2,
      pterminal IN VARCHAR2,
      porigen IN VARCHAR2,
      psinterf IN OUT NUMBER,
      perror OUT VARCHAR2,
      pusuario IN VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_cobro_recibo(
      pempresa IN NUMBER,
      pnrecibo IN NUMBER,
      pterminal IN VARCHAR2,
      pcobrado OUT NUMBER,
      psinterf IN OUT NUMBER,
      perror OUT VARCHAR2,
      pusuario IN VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_abrir_puesto(
      pempresa IN NUMBER,
      pusuario IN VARCHAR2,
      ppassword IN VARCHAR2,
      psinterf IN OUT NUMBER,
      poficina OUT NUMBER,
      ptermlog OUT NUMBER,
      perror OUT VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_cerrar_puesto(
      pempresa IN NUMBER,
      pusuario IN VARCHAR2,
      psinterf IN OUT NUMBER,
      perror OUT VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_proceso_alta(
      pempresa IN NUMBER,
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pop IN VARCHAR2,
      pusuario IN VARCHAR2,
      psinterf IN OUT NUMBER,
      perror OUT VARCHAR2)
      RETURN NUMBER;

   -- Bug 21458/108087 - 23/02/2012 - AMC
   -- Se añaden nuevos parametros de entrada
   FUNCTION f_convertir_documento(
      pempresa IN NUMBER,
      ptipoorigen IN VARCHAR2,
      ptipodestino IN VARCHAR2,
      pficheroorigen IN VARCHAR2,
      pficherodestino IN VARCHAR2,
      pplantillaorigen IN VARCHAR2,   --BUG11404 - JTS - 16/10/2009
      psinterf IN OUT NUMBER,
      pfirmadigital IN VARCHAR2,
      pfirmadigitalalias IN VARCHAR2,
      pfirmaelectronicacliente IN VARCHAR2,
      pfirmaelectronicaclienteimagen IN VARCHAR2,
      perror OUT VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_obtener_valor_axis(pemp IN VARCHAR2, pcampo IN VARCHAR2, pvalemp IN VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION f_obtener_valor_emp(pemp IN VARCHAR2, pcampo IN VARCHAR2, pvalaxis IN VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION traspaso_tablas_per_host(
      psinterf IN NUMBER,
      pficticia_sperson OUT estper_personas.sperson%TYPE,
      psseguro IN NUMBER,
      pcagente IN agentes.cagente%TYPE,
      pcidioma IN idiomas.cidioma%TYPE,
      pcempres IN empresas.cempres%TYPE,
      p_modo IN VARCHAR2   -- Bug 11948
                        )
      --BUG8644-17032009-XVM
   RETURN t_ob_error;

   PROCEDURE traspaso_tablas_ccc_host(
      psinterf IN NUMBER,
      psperson IN estper_personas.sperson%TYPE,
      pcagente IN agentes.cagente%TYPE,
      porigen IN VARCHAR2 DEFAULT 'EST');

   FUNCTION f_get_datosper_host(
      psinterf IN VARCHAR2,
      psip OUT VARCHAR2,
      pfnacimi OUT DATE,
      ptdocidentif OUT VARCHAR2,
      psexo OUT NUMBER,
      pctipide OUT NUMBER)
      RETURN NUMBER;

   -- Mantis 9692.#6.
   FUNCTION f_traspaso_int_his
      RETURN NUMBER;

   FUNCTION f_lista_polizas(
      pcempres IN NUMBER,
      psnip IN VARCHAR2,
      pcsituac IN NUMBER,
      vsquery OUT VARCHAR2,
      psinterf OUT NUMBER,
      perror OUT VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_extracto_polizas(
      pcempres IN NUMBER,
      pnpoliza IN NUMBER,
      pfini IN DATE,
      pffin IN DATE,
      vsquery OUT VARCHAR2,
      psinterf OUT NUMBER,
      perror OUT VARCHAR2)
      RETURN NUMBER;

   -- Bug 0021190 - 10/04/2012 - JMF
   FUNCTION f_extracto_polizas_asegurado(
      pcempres IN NUMBER,
      pnpoliza IN NUMBER,
      pfini IN DATE,
      pffin IN DATE,
      vsquery OUT VARCHAR2,
      psinterf OUT NUMBER,
      perror OUT VARCHAR2,
      psnip IN VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_detalle_poliza(
      pnpoliza IN NUMBER,
      psinterf OUT NUMBER,
      psquery OUT VARCHAR2,
      perror OUT VARCHAR2)
      RETURN NUMBER;

   -- Bug 0021190 - 10/04/2012 - JMF
   FUNCTION f_detalle_poliza_asegurado(
      pnpoliza IN NUMBER,
      psinterf OUT NUMBER,
      psquery OUT VARCHAR2,
      perror OUT VARCHAR2,
      psnip IN VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_get_listado_doc(
      pempresa IN NUMBER,
      psip IN VARCHAR2,
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      psinterf IN OUT NUMBER,
      perror OUT VARCHAR2,
      pusuario IN VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_get_detalle_doc(
      pempresa IN NUMBER,
      pid IN VARCHAR2,
      pdestino IN VARCHAR2,
      pnombre IN VARCHAR2,
      psinterf IN OUT NUMBER,
      perror OUT VARCHAR2,
      pusuario IN VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_get_datoscontratos(
      pempresa IN NUMBER,
      psperson IN VARCHAR2,
      pterminal IN VARCHAR2,
      poperador IN VARCHAR2,
      poficina IN NUMBER,
      porigen IN VARCHAR2,
      psinterf IN OUT NUMBER,
      perror OUT VARCHAR2)
      RETURN NUMBER;

   -- Bug 14365 - 01/09/2010 - FAL - Alta de personas en el C.I
   FUNCTION f_alta_persona(
      pempresa IN NUMBER,
      psip IN VARCHAR2,
      pterminal IN VARCHAR2,
      psinterf IN OUT NUMBER,
      perror OUT VARCHAR2,
      pusuario IN VARCHAR2,
      pobligarepr IN NUMBER DEFAULT 0,
      paltamod IN VARCHAR2 DEFAULT 'ALTA',
      pdigitoide IN NUMBER DEFAULT 0,   -- BUG 21270/106644 - 08/02/2012 - JMP
      penviopers IN VARCHAR2 DEFAULT NULL,
      pdiferido IN NUMBER DEFAULT 0)   -- ini BUG 0026318 -- ETM -- 28/05/2013
      RETURN NUMBER;

   -- Fi Bug 14365 - 01/09/2010 - FAL

   -- Bug 14365 - 26/08/2010 - SRA - función que devuelve un cursor con todas las equivalencias entre códigos origen de la empresa
   -- y su código equivalente en AXIS
   -- BUG 21546_108727- 23/02/2012 - JLTS - Se quita la utilizacion de mensajes.
   FUNCTION f_obtener_valores_axis(pemp IN VARCHAR2, pcampo IN VARCHAR2)
      RETURN sys_refcursor;

   -- Bug 14365 - 26/08/2010 - SRA - función que devuelve un cursor con todas las equivalencias entre códigos origen en AXIS
   -- y su código equivalente en la empresa

   -- BUG 21546_108727 23/02/2012 - JLTS - Se quita la utilizacion de mensajes.
   FUNCTION f_obtener_valores_emp(pemp IN VARCHAR2, pcampo IN VARCHAR2)
      RETURN sys_refcursor;

   --Ini Bug.: 17247 - ICV - 07/02/2011
   /*************************************************************************
                  Función que se llamará al emitir un pago para comunicarse con AXISCONNECT
      pempres number : Codigo de empresa
      paccion number : Acción con la que se llama (1.- Emisión, 2.- Consulta, 3.- Actualización)
      ptipopago number : Tipo de pago (1- Pago de siniestro, 2- Pago de prestación de renta, 3- Pago de renta, 4- Emisión recibo)
      pidPago number: Identificador del pago (srecren  (2,3), sidepag (1), nrecibo (4))
      pidmovimiento number: Número de movimiento (nmovpag de movpagren para tipo (2,3), nmovpag de sin tramita_movpago para tipo 1, smovrec de movrecibos para tipo 4)
      pnumevento number : Número de evento
      return    NUMBER         : 0 -> Traspàs correcte.
                               : 1 -> Error.
   *************************************************************************/
   FUNCTION f_emision_pagorec(
      pempresa IN NUMBER,
      paccion IN NUMBER,
      ptipopago IN NUMBER,
      pidpago IN NUMBER,
      pidmovimiento IN NUMBER,
      pterminal IN VARCHAR2,
      pemitido OUT NUMBER,
      psinterf IN OUT NUMBER,
      perror OUT VARCHAR2,
      pusuario IN VARCHAR2,
      pnumevento IN NUMBER DEFAULT NULL,
      pcoderrorin IN NUMBER DEFAULT NULL,
      pdescerrorin IN VARCHAR2 DEFAULT NULL,
      ppasocuenta IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

   --Fin bug.: 17247
   --IAXIS 4504 Creacion de funcion de conexion a sap contabilidad 
   /*************************************************************************
      Función que se llamará al emitir un pago para comunicarse con AXISCONNECT
      pempres number : Codigo de empresa
      paccion number : Acción con la que se llama (1.- Emisión, 2.- Consulta, 3.- Actualización)
      ptipopago number : Tipo de pago (1- Pago de siniestro, 2- Pago de prestación de renta, 3- Pago de renta, 4- Emisión recibo)
      pidPago number: Identificador del pago (srecren  (2,3), sidepag (1), nrecibo (4))
      pidmovimiento number: Número de movimiento (nmovpag de movpagren para tipo (2,3), nmovpag de sin tramita_movpago para tipo 1, smovrec de movrecibos para tipo 4)
      pnumevento number : Número de evento
      return    NUMBER         : 0 -> Traspàs correcte.
                               : 1 -> Error.
   *************************************************************************/
   FUNCTION f_contab_siniestro(
      pempresa IN NUMBER,
      paccion IN NUMBER,
      ptipopago IN NUMBER,
      pidpago IN NUMBER,
      pidmovimiento IN NUMBER,
      pterminal IN VARCHAR2,
      pemitido OUT NUMBER,
      psinterf IN OUT NUMBER,
      perror OUT VARCHAR2,
      pusuario IN VARCHAR2,
      pnumevento IN NUMBER DEFAULT NULL,
      pcoderrorin IN NUMBER DEFAULT NULL,
      pdescerrorin IN VARCHAR2 DEFAULT NULL,
      ppasocuenta IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

   --IAXIS 4504 Creacion de funcion de conexion a sap contabilidad 
	--IAXIS 5194 Creacion de funcion de conexion a sap contabilidad reservas
   /*************************************************************************
      Función que se llamará al emitir un pago para comunicarse con AXISCONNECT
      pempres number : Codigo de empresa
      paccion number : Acción con la que se llama (1.- Emisión, 2.- Consulta, 3.- Actualización)
      ptipopago number : Tipo de pago (1- Pago de siniestro, 2- Pago de prestación de renta, 3- Pago de renta, 4- Emisión recibo)
      pidPago number: Identificador del pago (srecren  (2,3), sidepag (1), nrecibo (4))
      pidmovimiento number: Número de movimiento (nmovpag de movpagren para tipo (2,3), nmovpag de sin tramita_movpago para tipo 1, smovrec de movrecibos para tipo 4)
      pnumevento number : Número de evento
      return    NUMBER         : 0 -> Traspàs correcte.
                               : 1 -> Error.
   *************************************************************************/
   FUNCTION f_contab_siniestro_res(
      pempresa IN NUMBER,
      paccion IN NUMBER,
      ptipopago IN NUMBER,
      pidpago IN NUMBER,
      pidmovimiento IN NUMBER,
      pterminal IN VARCHAR2,
      pemitido OUT NUMBER,
      psinterf IN OUT NUMBER,
      perror OUT VARCHAR2,
      pusuario IN VARCHAR2,
      pnumevento IN NUMBER DEFAULT NULL,
      pcoderrorin IN NUMBER DEFAULT NULL,
      pdescerrorin IN VARCHAR2 DEFAULT NULL,
      ppasocuenta IN NUMBER DEFAULT NULL,
      pnsinies in sin_siniestro.nsinies%type, 
      pntramit in number, 
      pctipres      in number, 
      pnmovres      in number,
      pnmovresdet   IN NUMBER,
      pcreexpre     IN NUMBER,
      pidres        IN NUMBER,
      pcmonres      IN NUMBER)
      RETURN NUMBER;
        --IAXIS 5194 Creacion de funcion de conexion a sap contabilidad reservas
   --Ini Bug.: 17389 - ETM - 17/02/2011
   /*************************************************************************
                 FUNTION F_PESQUISAR_EVENTO  nos devuelve la lista los recibos que están pendientes de actualizar en AXIS.
      pempresa IN NUMBER,
      ptipopago IN NUMBER,
      pidpago IN NUMBER,
      pterminal IN VARCHAR2,
      pconsulta OUT NUMBER,
      psinterf IN OUT NUMBER,
      perror OUT VARCHAR2,
      pusuario IN VARCHAR2
      pnumevento IN NUMBER
    La función devuelve  0 si ha ido bien 1 si hay error
   *************************************************************************/
   FUNCTION f_pesquisar_evento(
      pempresa IN NUMBER,
      ptipopago IN NUMBER,
      pidpago IN NUMBER,
      pterminal IN VARCHAR2,
      pconsulta OUT NUMBER,
      psinterf IN OUT NUMBER,
      perror OUT VARCHAR2,
      pusuario IN VARCHAR2,
      pnumevento IN NUMBER)
      RETURN NUMBER;

   --fiN Bug.: 17389 - ETM - 17/02/2011

   -- BUG18682:DRA:23/08/2011:Inici
   FUNCTION f_get_datos_host(pempresa IN NUMBER, psinterf IN OUT NUMBER, perror OUT VARCHAR2)
      RETURN NUMBER;

   -- BUG18682:DRA:23/08/2011:Fi
   FUNCTION f_crear_reproceso(
      psinterf IN NUMBER,
      pcinterf IN VARCHAR2,
      pcestado IN NUMBER,
      pcempres IN NUMBER,
      plineaini IN VARCHAR2,
      perror IN VARCHAR2,
      pcusuari IN VARCHAR2,
      pid1 IN NUMBER,
      pid2 IN NUMBER,
      ptipo IN NUMBER,
      psinterfpadre IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

   -- Bug 28644 - 24/10/2013 - JMG - #156855 Reproceso de interfaz de personas.
   PROCEDURE p_int_reprocesar(pcinterf IN VARCHAR2 DEFAULT NULL);

   FUNCTION f_tag(psinterf IN VARCHAR2, ptag IN VARCHAR2, pcampo IN VARCHAR2 DEFAULT 'TMENOUT')
      RETURN VARCHAR2;

   FUNCTION f_accion_reproceso(
      pidpago IN NUMBER,
      pidmovimiento IN NUMBER,
      ptipopago IN NUMBER,
      pcempres IN NUMBER,
      prepr OUT NUMBER)
      RETURN NUMBER;

   FUNCTION f_importe_financiacion_pdte(
      pcempres IN NUMBER,
      psseguro IN NUMBER,
      psinterf IN OUT NUMBER,
      pimporte OUT NUMBER,
      perror OUT VARCHAR2)
      RETURN NUMBER;

   -- Ini Bug 23687 - XVM - 09/10/2012
   /*************************************************************************
                  Función f_desencrip_pwd: función que obtiene el password desencriptado de un usurio
      param in  pcusuari:       Código de usuario
      param out ptexto          password desencriptado
      return                    0/nºerr -> Todo OK/Código de error
   *************************************************************************/
   FUNCTION f_desencrip_pwd(pcusuari IN VARCHAR2, ptexto OUT VARCHAR2)
      RETURN NUMBER;

   /*************************************************************************
                  Función f_cuerpo: función para recuperar el cuerpo de un correo
      param in  pscorreo:       Código de correo
      param in  pcidioma:       Código de idioma
      param in  pcusuari:       Código de usuario
      param out ptexto          Texto cuerpo
      return                    0/nºerr -> Todo OK/Código de error
   *************************************************************************/
   FUNCTION f_cuerpo(
      pscorreo IN NUMBER,
      pcidioma IN NUMBER,
      pcusuari IN VARCHAR2,
      ptexto OUT VARCHAR2)
      RETURN NUMBER;

   /*************************************************************************
                  Función f_asunto: función para recuperar el asunto de un correo
      param in  pscorreo:       Código de correo
      param in  pcidioma:       Código de idioma
      param out psubject        Texto asunto
      return                    0/nºerr -> Todo OK/Código de error
   *************************************************************************/
   FUNCTION f_asunto(pscorreo IN NUMBER, pcidioma IN NUMBER, psubject OUT VARCHAR2)
      RETURN NUMBER;

   /*************************************************************************
                  Función f_recordarpwd: su finalidad es enviar un correo al usuario
      a la dirección pasada por parámetro notificándole su password de acceso a la aplicación
      param in  pcempres:       Código de empresa
      param in  pcidioma:       Código de idioma
      param in  pcusuari:       Código de usuario
      param in  pto:            Dirección de correo a enviar (sería el "Para:" del correo)
      param out perror          Mensaje de error
      return                    0/nºerr -> Todo OK/Código de error
   *************************************************************************/
   FUNCTION f_recordarpwd(
      pcempres IN NUMBER,
      pcidioma IN NUMBER,
      pcusuari IN VARCHAR2,
      pto IN VARCHAR2,
      perror OUT VARCHAR2)
      RETURN NUMBER;

   -- Fin Bug 23687 - XVM - 09/10/2012

   -- Bug 024791 - 01/09/2010 - JLB -Nuevas interfaces de autos
   /*************************************************************************
      Función  f_ultimoSeguroVehiculo: Funcion para obtener último seguro vehiculo
       param in  pempresa:         Código de empresa
       param in  ptipomatricula:   Codigo de la moneda que quiere convertirse
       param in  pmatricula:  Codigo de la moneda que a la cual desea convertirse
       param out pfechaultimavig última vigencia
       paran out pcompani        compañia ultima vigencia
       param out mensajes          Mensajes de error
       return                      0 ok /nºerr -> Código de error
    *************************************************************************/
   FUNCTION f_ultimosegurovehiculo(
      pempresa IN NUMBER,
      ptipomatricula IN VARCHAR2,
      pmatricula IN VARCHAR2,
      pfechaultimavig OUT DATE,
      pcompani OUT NUMBER,
      psinterf IN OUT NUMBER,
      perror OUT VARCHAR2)
      RETURN NUMBER;

   /*************************************************************************
       Función  f_antiguedadConductor: Funcion para obtener el la antiguedad conductor en compañia
        param in  pempresa:         Código de empresa
        param in  ptipodoc:  Tipo de documento
        param in  pnnumide:  Identificador de persona fisica
        param out pantiguedad: antiguedad
        param out pcompani:    compañia
        param out psinterf:    codigo secuencial de interfaz
        param out terror          Mensajes de error
        return                      0 ok /nºerr -> Código de error
     *************************************************************************/
   FUNCTION f_antiguedadconductor(
      pempresa IN NUMBER,
      ptipodoc IN VARCHAR2,
      pnnumide IN VARCHAR2,
      pantiguedad OUT NUMBER,
      pcompani OUT NUMBER,
      psinies OUT NUMBER,
      psinterf IN OUT NUMBER,
      perror OUT VARCHAR2)
      RETURN NUMBER;

   /*************************************************************************
       Función  f_solicitar_inspeccion: Funcion para pedir orden de inspección
         param in  pempresa:         Código de empresa
         param in  psseguro:  Identificador de seguro
         param in  pnriesgo:  Identificador de riesgo
         param in  pnmovimi:  Identificador de movimiento
         param out ptabla:  Tablas sobre la que obtener datos 'EST' o Relase
         param out pnordenext:   Nº identificador de orden de petición
         param out psinterf:    codigo secuencial de interfaz
         param out terror            Mensajes de error
         return                      0 ok /nºerr -> Código de error
      *************************************************************************/
   FUNCTION f_solicitar_inspeccion(
      pempresa IN NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      pmotinspec IN NUMBER,
      ptabla IN VARCHAR2,
      pnordenext OUT NUMBER,
      psinterf IN OUT NUMBER,
      perror OUT VARCHAR2)
      RETURN NUMBER;

-- fin interfaces autos
   FUNCTION f_cont_reproceso(psinterf IN NUMBER, pestado IN NUMBER)
      RETURN NUMBER;

   PROCEDURE p_int_cont_reproceso(pcempres IN NUMBER);

   FUNCTION f_connect_estandar(
      pempresa IN NUMBER,
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      psinterf IN OUT NUMBER,
      perror OUT VARCHAR2,
      pxml IN CLOB,
      pop IN NUMBER,
      servicio IN VARCHAR2 DEFAULT NULL,
      pcinterf IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;
END pac_con;

/