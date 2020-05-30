--------------------------------------------------------
--  DDL for Package PAC_SEPA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_SEPA" AUTHID CURRENT_USER AS
      /*******************************************************************************
      FUNCION f_mandato_activo
      Descripcion: Saber si un mandato está activo para la cuenta bancaria y cobrador de una póliza o recibo.
                   Sí se informa el recibo lo busca el mandato de la cuenta bancaria y cobrador bancario del recibo,
                   sino buscará el de la póliza.
      Parámetros:
         psseguro: Número de seguro - Obligatorio
         pnrecibo: Número de recibo - Opcional - Se informa cuando queremos controlarlo por RECIBO
         pccobban: Código de cobrador bancario - Opcional
         pcbancar: Cuenta bancaria - Opcional
         pctipban: Tipo cuenta bancaria - Opcional
         psperson: Identificador de la persona  - Opcional

      Retorna un valor numérico:
      Devuelve un 1 cuando el mandato está activado, un 0 si no lo está y -1 cuando no existe mandato.

   */
   FUNCTION f_mandato_activo(
      psseguro IN recibos.sseguro%TYPE,
      pnrecibo IN recibos.nrecibo%TYPE DEFAULT NULL,
      pccobban IN recibos.ccobban%TYPE DEFAULT NULL,
      pcbancar IN recibos.cbancar%TYPE DEFAULT NULL,
      pctipban IN recibos.ctipban%TYPE DEFAULT NULL,
      psperson IN recibos.sperson%TYPE DEFAULT NULL)
      RETURN NUMBER;

   FUNCTION f_leer_file_rechazo(
      pfichero IN VARCHAR2,
      ppath IN VARCHAR2 DEFAULT NULL,
      pidrechazo OUT NUMBER)   -- BUG 0036506 - FAL - 10/12/2015 - Se añade ruta del directorio
      RETURN NUMBER;

   FUNCTION f_genera_xml_domis(pcempres IN NUMBER, piddomisepa IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_genera_xml_transferencias(pidtransf IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_genera_fichero_dom_trans(
      pmodaldomtrans IN VARCHAR2,
      pid IN NUMBER,
      pnombrefichero IN VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_get_mandatos(
      psseguro IN seguros.sseguro%TYPE,
      pccobban IN cobbancario.ccobban%TYPE,
      pcbancar IN recibos.cbancar%TYPE,
      pctipban IN recibos.ctipban%TYPE)
      RETURN mandatos%ROWTYPE;

   /*******************************************************************************
   FUNCION f_set_mandatos
         -- Descripcion
   Parámetros:
    Entrada :
      psseguro: Número de seguro - Obligatorio
      pnrecibo: Número de recibo - Opcional - Se informa cuando queremos controlarlo por RECIBO
      pcestado: Código de estado - Opcional - Solo informalo para forzar un estado en concreto.
      -- Los siguientes parámetros solo se informan desde el trigger de RECIBOS AIU_RECIBOS_SEPA,
      -- para evitar tener que hacer SELECT sobre recibos, y evitar el error que dice que la tabla está mutando.
      psperson: Identificador de la persona  - Opcional
      pcbancar: Cuenta bancaria - Opcional
      pctipban: Tipo cuenta bancaria - Opcional
      pccobban: Código de cobrador bancario - Opcional

     Retorna un valor numérico: 0 si ha grabado el traspaso y 1 si se ha producido algún error.
   ********************************************************************************/
   FUNCTION f_set_mandatos(
      psseguro IN recibos.sseguro%TYPE,
      pnrecibo IN recibos.nrecibo%TYPE DEFAULT NULL,
      pcestado IN mandatos.cestado%TYPE DEFAULT NULL,
      psperson IN recibos.sperson%TYPE DEFAULT NULL,
      pcbancar IN recibos.cbancar%TYPE DEFAULT NULL,
      pctipban IN recibos.ctipban%TYPE DEFAULT NULL,
      pccobban IN recibos.ctipban%TYPE DEFAULT NULL)
      RETURN NUMBER;

   /*******************************************************************************
    FUNCION f_caracteres_sepa

    Convierte un texto al estándar SEPA, eliminando los no soportados por SEPA y sustituyendo los
    no permitidos por en XML.

    Las características y contenido del mensaje deberán ajustarse a las reglas del esquema de adeudos
    directos SEPA. En el mismo se definen, entre otras reglas, los caracteres admitidos, que se ajustarán
    a los siguientes:

    Entrada: ptexto --> Texto a convertir
    Salida : vtexto --> Texto convertido

   *******************************************************************************/
   FUNCTION f_caracteres_sepa(ptexto IN VARCHAR2)
      RETURN VARCHAR2;
END pac_sepa;

/

  GRANT EXECUTE ON "AXIS"."PAC_SEPA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_SEPA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_SEPA" TO "PROGRAMADORESCSI";
