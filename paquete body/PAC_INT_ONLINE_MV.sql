--------------------------------------------------------
--  DDL for Package Body PAC_INT_ONLINE_MV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_INT_ONLINE_MV" 
IS
   FUNCTION f_obtener_dni (
      pctipdoc    IN       VARCHAR2,
      pdocident   IN       VARCHAR2,
      ptidenti    OUT      NUMBER
   )
      RETURN VARCHAR2
   IS
-------------------------------------------------------------------------------
--   Esta función retorna el DNI/NIF que se grabará en AXIS con los datos enviados
--     por Banca March. Si por algún motivo los datos enviados son incorrectos
--     se creará un código propio de AXIS (Z...). En cualquier caso, el código
--     enviado por Banca March se guardará en la tabla personas_mv.
-------------------------------------------------------------------------------
BEGIN
return null;
   END f_obtener_dni;

-----------------------------------
   FUNCTION f_crea_usuario (puser IN VARCHAR2, pnombre IN VARCHAR2)
      RETURN NUMBER
   IS
BEGIN
return null;
   END f_crea_usuario;

-----------------------------------
   FUNCTION f_borra_usuario (puser IN VARCHAR2)
      RETURN NUMBER
   IS
-------------------------------------------------------------------------------
--   Borra el usuario de base de datos puser (en principio se llama cuando ya
--     se ha creado el usuario (f_crea_usuario) del terminal financiero y se ha
--     producido un error que hace innecesario el usuario en esta bd)
-------------------------------------------------------------------------------
   BEGIN
return null;
   END f_borra_usuario;

-----------------------------------
   FUNCTION f_crea_dsi (puser IN VARCHAR2)
      RETURN NUMBER
   IS
-------------------------------------------------------------------------------
--   Inserta en la tabla dsiusurol.
-------------------------------------------------------------------------------
   BEGIN
return null;
   END f_crea_dsi;

-----------------------------------
/*   FUNCTION insertar_persona (
      p_out      IN       pac_xml_mv.rinfpersona_out,
      p_tfnos    IN       pac_xml_mv.ttelefonos,
      psseguro   IN       NUMBER,
      psperson   OUT      NUMBER
   )
      RETURN NUMBER
   IS
-------------------------------------------------------------------------------
--   Valida los datos de la persona que va a insertar e inserta una persona en
--     la base de datos. Inserta en personas, direcciones, contacto y personas_mv.
-------------------------------------------------------------------------------
   BEGIN
return null;
   END insertar_persona;

-----------------------------------
   FUNCTION insertar_prestamo (
      pprestamo_out    IN   pac_xml_mv.rdatosprestamo_out,
      ptitulares_out   IN   pac_xml_mv.ttitulares_out,
      pcuadro_out      IN   pac_xml_mv.tcuadroamort_out
   )
      RETURN NUMBER
   IS
-------------------------------------------------------------------------------
--   Valida los datos del préstamo que va a insertar e inserta el préstamo en
--     la base de datos. Inserta en prestamos, prestcapitales, prestcuadro y
--     presttitulares
-------------------------------------------------------------------------------
   BEGIN
return null;
	END insertar_prestamo;
*/
-----------------------------------
   FUNCTION f_pol_error (
      psseguro   IN   NUMBER,
      pnrecibo   IN   NUMBER,
      pctiperr   IN   NUMBER
   )
      RETURN NUMBER
   IS
-------------------------------------------------------------------------------
--   graba en la tabla int_mv_pol_error cuando se ha producido un error en
--     el alta de la póliza o en el adeudo del recibo.
--     pctiperr:
--          Adeudo recibo:
--                 0. error transacción
--              1. denegado por host
--              2. denegado por usuario
--              3. error axis
--         Alta póliza:
--                 4. error transacción
--              5. error axis
--         Cambio cuenta bancaria
--                 6. error transacción
--              7. error axis
--           Generico
--                  8. error no controlado
-------------------------------------------------------------------------------
BEGIN
return null;
   END f_pol_error;

-----------------------------------
/*   FUNCTION conectar_host (
      p_empleado   IN       VARCHAR2,
      p_out        OUT      pac_xml_mv.rlogon_out,
      p_error      OUT      VARCHAR2
   )
      RETURN NUMBER
   IS
-------------------------------------------------------------------------------
--   rellena la variable del tipo pac_xml_mv.rlogon_in y la pasa a la función
--     pac_xml_mv.validacion_logon que realizará la llamada al host para
--     validar el nombre de usuario como usuario válido de terminal financiero.
--     Los datos (como el nombre del usuario) retornarán en la variable del
--     tipo pac_xml_mv.rlogon_out
-------------------------------------------------------------------------------
BEGIN
return null;
   END conectar_host;

-----------------------------------
   FUNCTION buscar_personas (
      p_posicionamiento   IN OUT   VARCHAR2,
      p_formato           IN       VARCHAR2,
      p_empleado          IN       VARCHAR2,
      p_centroorigen      IN       VARCHAR2,
      p_sip               IN       VARCHAR2,
      p_docident          IN       VARCHAR2,
      p_nombre            IN       VARCHAR2,
      p_out               OUT      pac_xml_mv.tpersonas,
      p_error             OUT      VARCHAR2
   )
      RETURN NUMBER
   IS
-------------------------------------------------------------------------------
--   rellena la variable del tipo pac_xml_mv.rpersonas_in y la pasa a la función
--     pac_xml_mv.peticion_personas que realizará la llamada al host para
--     obtener los "identificadores" de todas las personas que cumplan con las.
--     condiciones pedidas. Los datos retornarán en la variable del tipo
--     pac_xml_mv.tpersonas.
-------------------------------------------------------------------------------
BEGIN
return null;
   END buscar_personas;

-----------------------------------
   FUNCTION buscar_infpersonas (
      p_empleado       IN       VARCHAR2,
      p_centroorigen   IN       VARCHAR2,
      p_sip            IN       VARCHAR2,
      p_out            OUT      pac_xml_mv.rinfpersona_out,
      p_tfnos          OUT      pac_xml_mv.ttelefonos,
      p_error          OUT      VARCHAR2
   )
      RETURN NUMBER
   IS
-------------------------------------------------------------------------------
--   rellena la variable del tipo pac_xml_mv.rpersonas_in y la pasa a la función
--     pac_xml_mv.peticion_infpersona que realizará la llamada al host para
--     obtener los datos de la persona. Estos datos retornará en las variables
--     del tipo pac_xml_mv.rinfpersona_out y pac_xml_mv.ttelefonos.
--   También grabaremos los datos recibidos en las tablas int_mv_persona y int_mv_telefono
--     para tener un històrico de los datos recibidos.
-------------------------------------------------------------------------------
BEGIN
return null;
   END buscar_infpersonas;
*/
-----------------------------------
   FUNCTION alta_poliza_host (
      p_empleado       IN       VARCHAR2,
      p_centroorigen   IN       VARCHAR2,
      p_foperacion     IN       DATE,
      p_sseguro        IN       NUMBER,
      p_tipocobro      IN       NUMBER,
      p_tipoerror      OUT      NUMBER,
      p_error          OUT      VARCHAR2
   )
      RETURN NUMBER
   IS
-------------------------------------------------------------------------------
--   rellena la variable del tipo pac_xml_mv.rpoliza_in y la pasa a la función
--     pac_xml_mv.alta_poliza que realizará la llamada al host para dar
--     de alta la póliza.
-------------------------------------------------------------------------------
BEGIN
return null;
   END alta_poliza_host;

-----------------------------------
   FUNCTION adeudo_recibo_host (
      p_formato        IN       VARCHAR2,
      p_empleado       IN       VARCHAR2,
      p_centroorigen   IN       VARCHAR2,
      p_foperacion     IN       DATE,
      p_nrecibo        IN       NUMBER,
      p_tipocobro      IN       NUMBER,
      p_aut            OUT      NUMBER,
      p_error          OUT      VARCHAR2
   )
      RETURN NUMBER
   IS
-------------------------------------------------------------------------------
--   rellena la variable del tipo pac_xml_mv.rrecibo_in y la pasa a la función
--     pac_xml_mv.adeudo_recibo que realizará la llamada al host para el
--     adeudo.
-------------------------------------------------------------------------------
BEGIN
return null;
   END adeudo_recibo_host;

-----------------------------------
   FUNCTION cambio_cuenta_bancaria (
      p_empleado       IN       VARCHAR2,
      p_centroorigen   IN       VARCHAR2,
      p_foperacion     IN       DATE,
      p_sseguro        IN       NUMBER,
      p_cccant         IN       VARCHAR2,
      p_cccnou         IN       VARCHAR2,
      p_tipoerror      OUT      NUMBER,
      p_error          OUT      VARCHAR2
   )
      RETURN NUMBER
   IS
-------------------------------------------------------------------------------
--   rellena la variable del tipo pac_xml_mv.rcuenta_in y la pasa a la función
--     pac_xml_mv.cambio de cuenta que realizará la llamada al host para el
--     cambio.
-------------------------------------------------------------------------------
BEGIN
return null;
   END cambio_cuenta_bancaria;

-----------------------------------
/*   FUNCTION datos_prestamo (
      p_empleado       IN       VARCHAR2,
      p_foperacion     IN       DATE,
      p_contrato       IN       VARCHAR2,
      pdatospres_out   OUT      pac_xml_mv.rdatosprestamo_out,
      ptitulares_out   OUT      pac_xml_mv.ttitulares_out,
      pcuadro_out      OUT      pac_xml_mv.tcuadroamort_out,
      p_tipoerror      OUT      NUMBER,
      p_error          OUT      VARCHAR2
   )
      RETURN NUMBER
   IS
-------------------------------------------------------------------------------
--   rellena la variable del tipo pac_xml_mv.rprestamo_in y la pasa a la función
--     pac_xml_mv.datos_prestamo que realizará la llamada al host para la obtención
--     de los datos del prestamo. La función del pac_xml_mv trabaja con la variable
--     de tipo pac_xml_mv.rprestamo_out, pero la función de este package devuelve
--     al form tres variables ya que el formulario no sabe tratar un tipo de datos
--     record con tablas dentro.
-------------------------------------------------------------------------------
BEGIN
return null;
   END datos_prestamo;
*/
-----------------------------------
   FUNCTION f_borrar_personas (psperson IN NUMBER)
      RETURN NUMBER
   IS
-------------------------------------------------------------------------------
--  borra todos los datos de la persona con psperson
-------------------------------------------------------------------------------
BEGIN
return null;
   END f_borrar_personas;

-----------------------------------
   FUNCTION f_borrar_persona_seguro (psseguro IN NUMBER)
      RETURN NUMBER
   IS
-------------------------------------------------------------------------------
--  busca todos los sperson relacionados con un sseguro y llama a la función
--    f_borrar_persona_seguro para borrar todos los datos de la persona
--  tiene COMMIT
-------------------------------------------------------------------------------
BEGIN
return null;
   END f_borrar_persona_seguro;

-----------------------------------
   FUNCTION f_persona_extranjera (
      psector         IN   VARCHAR2,
      pnacionalidad   IN   VARCHAR2
   )
      RETURN BOOLEAN
   IS
-------------------------------------------------------------------------------
--  Si el parámetro tiene el valor 2 Banca March define que la persona es
--    extranjera . Apartir de Junio de 2004 se autoriza a los alemanes e ingleses.
-------------------------------------------------------------------------------
BEGIN
return null;
   END f_persona_extranjera;

-----------------------------------
   FUNCTION f_persona_no_operativa (poperativa IN VARCHAR2)
      RETURN BOOLEAN
   IS
-------------------------------------------------------------------------------
--  Si el parámetro tiene el valor 1 Banca March define que la persona no es
--    operativa
-------------------------------------------------------------------------------
BEGIN
return null;
   END f_persona_no_operativa;

   FUNCTION f_tipo_amort_no_permitida (ptipoamort IN NUMBER, psproduc IN NUMBER)
      RETURN BOOLEAN
   IS
-------------------------------------------------------------------------------
--  No se permiten los tipos de amortización 3 (anticipos) o 5 (Préstamo
--   varias disposiciones).
--  Si el tipo de amortización es la 6 (cuenta crédito) y el producto no es
--   el 6 (personal prima única) tampoco se permite
-------------------------------------------------------------------------------
BEGIN
return null;
   END f_tipo_amort_no_permitida;

   FUNCTION f_tipo_prestamo_no_coincide (
      ptipoprest   IN   NUMBER,
      psproduc     IN   NUMBER,
      ptipoamort   IN   NUMBER
   )
      RETURN BOOLEAN
   IS
-------------------------------------------------------------------------------
--  No se permiten el tipo de prestamo personal (000, 001, 002, 004, 006) si el producto es un
--    hipotecario, ni el tipo de prestamo hipotecario (003, 005) si el producto es
--    personal.
--  Excepcion: si el producto es el 6 (personal prima única) y el tipo de amortización
--   es el 6 (cuenta crédito) no debe comprobarse el tipo de préstamo (personal o
--   hipotecario)
-------------------------------------------------------------------------------
BEGIN
return null;
   END f_tipo_prestamo_no_coincide;

   FUNCTION f_datosprest_dif (
      pctapres     IN   VARCHAR2,
      pctipamort   IN   NUMBER,
      pctipint     IN   NUMBER,
      pctippres    IN   NUMBER
   )
      RETURN BOOLEAN
   IS
-------------------------------------------------------------------------------
--  Siempre que importemos el mismo préstamo comprobamos que el tipo de amortización,
--   el tipo de interés y el tipo de préstamo sea el mismo, ya que se ha definido
--   que estos datos nunca cambiará en un prestamo.
-------------------------------------------------------------------------------
BEGIN
return null;
   END f_datosprest_dif;

/*   FUNCTION f_titulares_dif_mismo_prestamo (
      pctapres     IN   VARCHAR2,
      ptitulares   IN   pac_xml_mv.ttitulares_out
   )
      RETURN BOOLEAN
   IS
-------------------------------------------------------------------------------
--  Siempre que importemos el mismo préstamo comprobamos que los títulares
--   sean los mismos, ya que se ha definido que un prestamo núnca cambiará de
--   titulares.
-------------------------------------------------------------------------------
BEGIN
  RETURN null;

   END f_titulares_dif_mismo_prestamo;
*/
   FUNCTION f_domicilio_no_valido (ptipodomicilio IN VARCHAR2)
      RETURN BOOLEAN
   IS
BEGIN
  RETURN null;

   END f_domicilio_no_valido;

   FUNCTION inserta_pob_cp_extranjero (
      pcprovin   IN       NUMBER,
      ptpoblac   IN       VARCHAR2,
      pcpoblac   OUT      NUMBER
   )
      RETURN NUMBER
   IS
BEGIN
  RETURN null;
   END inserta_pob_cp_extranjero;

   FUNCTION f_ins_solprestcuadro (psinterf IN NUMBER, pssolici IN NUMBER)
      RETURN NUMBER
   IS
BEGIN
  RETURN null;

   END f_ins_solprestcuadro;
END pac_int_online_mv;

/

  GRANT EXECUTE ON "AXIS"."PAC_INT_ONLINE_MV" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_INT_ONLINE_MV" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_INT_ONLINE_MV" TO "PROGRAMADORESCSI";
