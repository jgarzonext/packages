--------------------------------------------------------
--  DDL for Package PAC_XML_MV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_XML_MV" AUTHID CURRENT_USER IS
------------------------------------------------------
----variable que contendrá la secuencia de la interfaz
   vsinterf       int_mensajes.sinterf%TYPE;   /* NUMBER;    */

   PROCEDURE p_inicializar_sinterf;

   FUNCTION f_obtener_sinterf
      RETURN NUMBER;

------------------------------------------------------
------  LOGON (4200) ---------------------------------
------------------------------------------------------
   TYPE rlogon_in IS RECORD(
      transaccion    VARCHAR2(100),
      VERSION        VARCHAR2(3),
      formato        VARCHAR2(100),
      empleado       VARCHAR2(5),
      fechaoperacion VARCHAR2(8)
   );

   TYPE rlogon_out IS RECORD(
      centroorigen   VARCHAR2(4),
      nombrepersona  VARCHAR2(70)
   );

   FUNCTION validacion_logon(p_in IN rlogon_in, p_out OUT rlogon_out, p_error OUT VARCHAR2)
      RETURN NUMBER;

------------------------------------------------------
------  PERSONAS (4000, 4001) ------------------------
------------------------------------------------------
   TYPE rpersonas_in IS RECORD(
      transaccion    VARCHAR2(100),
      formato        VARCHAR2(100),
      empleado       VARCHAR2(5),
      centroorigen   VARCHAR2(4),
      clavesip       personas.snip%TYPE,
      tipodocumento  VARCHAR2(1),
      docidentif     VARCHAR2(10),
      apellido1      VARCHAR2(40),
      apellido2      VARCHAR2(40),
      nombrepersona  VARCHAR2(40),
      posicionamiento VARCHAR2(15)
   );

   TYPE rpersonas_out IS RECORD(
      clavesip       personas.snip%TYPE,
      tipodocumento  VARCHAR2(1),
      docidentif     VARCHAR2(10),
      apellido1      VARCHAR2(40),
      apellido2      VARCHAR2(40),
      nombrepersona  VARCHAR2(40),
      tipopersona    VARCHAR2(1),
      posicionamiento VARCHAR2(15),
      secuencia      VARCHAR2(3)
   );

   TYPE rtelefono IS RECORD(
      tipotelefono   NUMBER(1),
      desc_tipotelefono VARCHAR2(50),
      prefijotelefono NUMBER(5),
      numerotelefono NUMBER(13)
   );

   TYPE ttelefonos IS TABLE OF rtelefono
      INDEX BY BINARY_INTEGER;

   TYPE rinfpersona_out IS RECORD(
      clavesip       personas.snip%TYPE,
      tipodocumento  VARCHAR2(1),
      docidentif     VARCHAR2(10),
      apellido1      VARCHAR2(40),
      apellido2      VARCHAR2(40),
      nombrepersona  VARCHAR2(40),
      tipopersona    VARCHAR2(1),
      desc_tipopersona VARCHAR2(50),
      sector         VARCHAR2(1),
      desc_sector    VARCHAR2(50),
      sexo           VARCHAR2(1),
      desc_sexo      VARCHAR2(50),
      estadocivil    VARCHAR2(1),
      desc_estadocivil VARCHAR2(50),
      nacionalidad   VARCHAR2(4),
      desc_nacionalidad VARCHAR2(200),
      fechanacimiento VARCHAR2(8),
      fechaalta      VARCHAR2(8),
      fechabaja      VARCHAR2(8),
      cnae           VARCHAR2(5),
      desc_cnae      VARCHAR2(200),
      cno            VARCHAR2(4),
      desc_cno       VARCHAR2(200),
      sitconcursal   VARCHAR2(1),
      pais           VARCHAR2(4),
      desc_pais      VARCHAR2(200),
      codigopostal   codpostal.cpostal%TYPE,
      --3606 jdomingo 29/11/2007  canvi format codi postal
      poblacion      VARCHAR2(30),
      desc_poblacion VARCHAR2(50),
      tipodomicilio  VARCHAR2(3),
      desc_tipodomicilio VARCHAR2(50),
      nombrecalle    VARCHAR2(30),
      numeropuerta   VARCHAR2(5),
      otrosdatos     VARCHAR2(10),
      web            VARCHAR2(40),
      email          VARCHAR2(40),
      centrogestor   VARCHAR2(4),
      clavegestor    VARCHAR2(7),
      ipersonaoper   VARCHAR2(1),
      iinstitucion   VARCHAR2(1),
      icliente       VARCHAR2(1)
   );

   TYPE tpersonas IS TABLE OF rpersonas_out
      INDEX BY BINARY_INTEGER;

   --
   -- Definición de variables globales
   vpersonas      tpersonas;

   --
   PROCEDURE extraer_nombre(
      p_nom IN VARCHAR2,
      p_nombre OUT VARCHAR2,
      p_apellido1 OUT VARCHAR2,
      p_apellido2 OUT VARCHAR2);

   FUNCTION peticion_personas(p_in rpersonas_in, p_out OUT tpersonas, p_error OUT VARCHAR2)
      RETURN NUMBER;

   FUNCTION peticion_infpersona(
      p_in IN rpersonas_in,
      p_out OUT rinfpersona_out,
      p_tfnos OUT ttelefonos,
      p_error OUT VARCHAR2)
      RETURN NUMBER;

------------------------------------------------------
------  POLIZAS (4201) ---------------------------------
------------------------------------------------------
   TYPE rpoliza_in IS RECORD(
      transaccion    VARCHAR2(100),
      VERSION        VARCHAR2(3),
      formato        VARCHAR2(100),
      empleado       VARCHAR2(5),
      centroorigen   VARCHAR2(4),
      fechaoperacion VARCHAR2(8),
      --póliza
      plzaplicacion  VARCHAR2(3),
      plzempresa     VARCHAR2(2),
      plzcentro      VARCHAR2(4),
      plzafijo       VARCHAR2(3),
      plzncontrato   VARCHAR2(7),
      plzdigito      VARCHAR2(1),
      producto       VARCHAR2(6),
      impnominal     NUMBER,   -- NUMBER(15, 2),
      feefecto       VARCHAR2(8),
      fevencimiento  VARCHAR2(8),
      --contrato asociado
      asoaplicacion  VARCHAR2(3),
      asoempresa     VARCHAR2(2),
      asocentro      VARCHAR2(4),
      asoafijo       VARCHAR2(3),
      asoncontrato   VARCHAR2(7),
      asodigito      VARCHAR2(1),
      --contrato vinculado
      vinaplicacion  VARCHAR2(3),
      vinempresa     VARCHAR2(2),
      vincentro      VARCHAR2(4),
      vinafijo       VARCHAR2(3),
      vinncontrato   VARCHAR2(7),
      vindigito      VARCHAR2(1),
      --domicilio
      pais           VARCHAR2(4),
      provincia      VARCHAR2(2),
      distrito       VARCHAR2(3),
      poblacion      VARCHAR2(30),
      tipocalle      VARCHAR2(3),
      nombrecalle    VARCHAR2(30),
      numeropuerta   VARCHAR2(5),
      otrosdatos     VARCHAR2(10)
   );

   TYPE rtomadores_in IS RECORD(
      clavesip       personas.snip%TYPE
   );

   TYPE ttomadores IS TABLE OF rtomadores_in
      INDEX BY BINARY_INTEGER;

   FUNCTION alta_poliza(p_in IN rpoliza_in, p_tomadores_in IN ttomadores, p_error OUT VARCHAR2)
      RETURN NUMBER;

------------------------------------------------------
------  RECIBOS (4202) ---------------------------------
------------------------------------------------------
   TYPE rrecibo_in IS RECORD(
      transaccion    VARCHAR2(100),
      VERSION        VARCHAR2(3),
      formato        VARCHAR2(100),
      empleado       VARCHAR2(5),
      centroorigen   VARCHAR2(4),
      fechaoperacion VARCHAR2(8),
      --datos cobro
      tipocobro      NUMBER(1),
      --contrato adeudo
      conaplicacion  VARCHAR2(3),
      conempresa     VARCHAR2(2),
      concentro      VARCHAR2(4),
      conafijo       VARCHAR2(3),
      conncontrato   VARCHAR2(7),
      condigito      VARCHAR2(1),
      --datos adeudo
      valautorizacion VARCHAR2(1),
      naturalezaadeud NUMBER(1),
      fechavalor     VARCHAR2(8),
      conceptoapunte VARCHAR2(3),
      importe        NUMBER,   -- NUMBER(15, 2),
      poliza         VARCHAR2(25),
      --poliza
      plzaplicacion  VARCHAR2(3),
      plzempresa     VARCHAR2(2),
      plzcentro      VARCHAR2(4),
      plzafijo       VARCHAR2(3),
      plzncontrato   VARCHAR2(7),
      plzdigito      VARCHAR2(1),
      producto       VARCHAR2(6),
      --datos movimiento libreta
      numeromvto     NUMBER(3),
      fechaefecto    VARCHAR2(8),
      naturaleza     NUMBER(1),
      conceptoapmvto VARCHAR2(3),
      importemvto    NUMBER,   -- NUMBER(15, 2),
      valorprovision NUMBER,   -- NUMBER(15, 2),
      valorvencim    NUMBER,   -- NUMBER(15, 2),
      valorfallecim  NUMBER,   -- NUMBER(15, 2),
      --contrato abono
      aboaplicacion  VARCHAR2(3),
      aboempresa     VARCHAR2(2),
      abocentro      VARCHAR2(4),
      aboafijo       VARCHAR2(3),
      aboncontrato   VARCHAR2(7),
      abodigito      VARCHAR2(1),
      --datos abono
      aboconceptoapun VARCHAR2(3),
      --autorizacion disponible
      autdisponible  NUMBER(1)
   );

   TYPE rrecibo_out IS RECORD(
      empleado       NUMBER(4),
      centroorigen   NUMBER(4),
      feoperacion    VARCHAR2(8),
      autaplicacion  NUMBER(3),
      auttitular     VARCHAR2(40),
      autasocentro   NUMBER(5),
      autdigitoctrl  NUMBER(1),
      autasocafijo   NUMBER(3),
      autcontrato    NUMBER(7),
      autdigcontrato NUMBER(1),
      autclaconcepto NUMBER(3),
      autreferencia  NUMBER(11),
      autclamoneda   NUMBER(3),
      autimporte     NUMBER(15, 2),
      autsigno       NUMBER(1),
      autfevalor     VARCHAR2(8),
      autfevento     VARCHAR2(8),
      autlimcredito  NUMBER,   -- NUMBER(15, 2),
      autlimdescub   NUMBER,   -- NUMBER(15, 2),
      autsaldo       NUMBER,   -- NUMBER(15, 2),
      autretenciones NUMBER,   -- NUMBER(15, 2),
      autriesgo      NUMBER,   -- NUMBER(15, 2),
      autdisponible  NUMBER   -- NUMBER(15, 2)
   );

   p_rec_out      rrecibo_out;

   TYPE rmotaut_out IS RECORD(
      codautoriz     VARCHAR2(5),
      errordenom     VARCHAR2(40),
      ampliacion     VARCHAR2(40)
   );

   TYPE tmotaut_out IS TABLE OF rmotaut_out
      INDEX BY BINARY_INTEGER;

   p_motaut_out   tmotaut_out;

   TYPE raut_in IS RECORD(
      autcodautoriz  NUMBER(1)
   );

   TYPE taut_in IS TABLE OF raut_in
      INDEX BY BINARY_INTEGER;

   FUNCTION adeudo_recibo(p_in IN rrecibo_in, p_aut OUT NUMBER, p_error OUT VARCHAR2)
      RETURN NUMBER;

------------------------------------------------------
------  CAMBIO CUENTA (4205) ---------------------------------
------------------------------------------------------
------------------------------------------------------
   TYPE rcuenta_in IS RECORD(
      transaccion    VARCHAR2(100),
      VERSION        VARCHAR2(3),
      formato        VARCHAR2(100),
      empleado       VARCHAR2(5),
      centroorigen   VARCHAR2(4),
      fechaoperacion VARCHAR2(8),
      --póliza
      plzaplicacion  VARCHAR2(3),
      plzempresa     VARCHAR2(2),
      plzcentro      VARCHAR2(4),
      plzafijo       VARCHAR2(3),
      plzncontrato   VARCHAR2(7),
      plzdigito      VARCHAR2(1),
      --contrato asociado actual
      cccact         seguros.cbancar%TYPE,
      --nuevo contrato asociado
      cccnou         seguros.cbancar%TYPE
   );

   FUNCTION cambio_cuenta(p_in IN rcuenta_in, p_error OUT VARCHAR2)
      RETURN NUMBER;

------------------------------------------------------
------  DATOS PRESTAMO (4203) ---------------------------------
------------------------------------------------------
------------------------------------------------------
   TYPE rprestamo_in IS RECORD(
      transaccion    VARCHAR2(100),
      VERSION        VARCHAR2(3),
      formato        VARCHAR2(100),
      empleado       VARCHAR2(5),
      centroorigen   VARCHAR2(4),
      fechaoperacion VARCHAR2(8),
      --prestamo
      conaplicacion  VARCHAR2(3),
      conempresa     VARCHAR2(2),
      concentro      VARCHAR2(4),
      conafijo       VARCHAR2(3),
      conncontrato   VARCHAR2(7),
      condigito      VARCHAR2(1),
      posicionamiento VARCHAR2(15)
   );

   TYPE rdatosprestamo_out IS RECORD(
      prestamo       VARCHAR2(20),
      tipoamort      VARCHAR2(1),
      tipointeres    VARCHAR2(1),
      tipoprest      VARCHAR2(3),
      capital        NUMBER,   -- NUMBER(15, 2),
      fechavencimiento VARCHAR2(8),
      fechabaja      VARCHAR2(8)
   );

   TYPE rtitulares_out IS RECORD(
      clavesip       personas.snip%TYPE,
      nordtitular    VARCHAR2(2),
      cldocumento    VARCHAR2(11),
      primertitular  VARCHAR2(40)
   );

   TYPE ttitulares_out IS TABLE OF rtitulares_out
      INDEX BY BINARY_INTEGER;

   TYPE rcuadroamort_out IS RECORD(
      fechavencimiento VARCHAR2(8),
      capital        NUMBER,   -- NUMBER(15, 2),
      interes        NUMBER,   -- NUMBER(15, 2),
      capitalpdte    NUMBER   -- NUMBER(15, 2)
   );

   TYPE tcuadroamort_out IS TABLE OF rcuadroamort_out
      INDEX BY BINARY_INTEGER;

   TYPE rprestamo_out IS RECORD(
      posicionamiento VARCHAR2(15),
      datospres      rdatosprestamo_out,
      titulares      ttitulares_out,
      cuadroamort    tcuadroamort_out
   );

   FUNCTION datos_prestamo(
      p_in IN rprestamo_in,
      p_out IN OUT rprestamo_out,
      p_error OUT VARCHAR2)
      RETURN NUMBER;

------------------------------------------------------
------------------------------------------------------
------------------------------------------------------

   -- Procedimienos para la gestión  de la autorización del recibo
   --
   PROCEDURE retorno_rec(
      p_auttitular IN OUT VARCHAR2,
      p_autasocentro IN OUT NUMBER,
      p_autdigitoctrl IN OUT NUMBER,
      p_autasocafijo IN OUT NUMBER,
      p_autcontrato IN OUT NUMBER,
      p_autdigcontrato IN OUT NUMBER,
      p_autclaconcepto IN OUT NUMBER,
      p_autclamoneda IN OUT NUMBER,
      p_autimporte IN OUT NUMBER,
      p_autsigno IN OUT NUMBER,
      p_autfevalor IN OUT VARCHAR2,
      p_autfevento IN OUT VARCHAR2,
      p_autlimcredito IN OUT NUMBER,
      p_autlimdescub IN OUT NUMBER,
      p_autsaldo IN OUT NUMBER,
      p_autretenciones IN OUT NUMBER,
      p_autriesgo IN OUT NUMBER,
      p_autdisponible IN OUT NUMBER);

   PROCEDURE retorno_rec_mot(
      p_codautoriz IN OUT VARCHAR2,
      p_errordenom IN OUT VARCHAR2,
      p_ampliacion IN OUT VARCHAR2,
      p_rec IN NUMBER);

   PROCEDURE retorno_num_mot(p_rec IN OUT NUMBER);
END pac_xml_mv;

/

  GRANT EXECUTE ON "AXIS"."PAC_XML_MV" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_XML_MV" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_XML_MV" TO "PROGRAMADORESCSI";
