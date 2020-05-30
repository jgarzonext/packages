--------------------------------------------------------
--  DDL for Package PAC_IDE_PERSONA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_IDE_PERSONA" 
IS
/******************************************************************************
   NOMBRE:    PAC_IDE_PERSONAS
   PROPÓSITO: Funciones para gestionar validaciones de identificación de personas

   REVISIONES:
   Ver        Fecha        Autor       Descripción
   ---------  ----------  ---------  ------------------------------------
   1.0        13-05-2010  AVT         1. Creación del package. BUG: 14467
   2.0        13-09-2011  JMF         2. 0019426: Definir producto Transportes Individual para GIP
   3.0        21-11-2011  APD         3. 0019587: LCOL_P001 - PER - Validaciones dependiendo del tipo de documento
   4.0        11/12/2012  ETM         4. 0024780: RSA 701 - Preparar personas para Chile
   5.0        27/11/2015  YDA         5. 0038922: Se crea la función f_validar_nif_malta
******************************************************************************/
/*****************************************************************************
  Func?o: Criada para validar o nif Angolano

 Tipo de Documento - Regra de validac?o - Tamanho - Tipo   Digito  Digito
                                                                Inicial Fim
 NIF EMPRESA M?E                        - 10 Numerico     - 5      - n.a
 NIF EMPRESA FILIAL                     - 11 Alfanumerico - 5      - Letra
 NIF P.S.T. CONTA PROPRIA / ACTIVIDADES - 10 Numerico     - 2      - n.a
 NIF P.S.T. CONTA OUTREM                - 15 Alfanumerico - 1      - n.a.
 NIF INSTITUCIONAIS                     - 10 Numerico     - 7      - n.a.
 NIF ANTIGO                             - 15 alfanumericos - n.a.  - n.a.
 CART?O DE RESIDENCIA                   - 15 alfanumericos - n.a.  - n.a.
 BI                                     - 15 alfanumericos - n.a.  - n.a.
 BI ANTIGO                              - 15 alfanumericos - n.a.  - n.a.
 <Nenhum documento>                     - Z999999

      14502 13-05-2010 AVT - adaptación NIFs Angola basada en la
                          F_VALIDA_NIF_ANGOLA de Asphales
*****************************************************************************/
   FUNCTION f_validar_nif_ang(tipodoc IN VARCHAR, nnumnif IN VARCHAR)
      RETURN NUMBER;

   -- BUG 0019426 - 13-09-2011 - JMF : Validación nif Portugal
   FUNCTION f_validar_nif_por(pctipide IN NUMBER, pnnumide IN VARCHAR)
      RETURN NUMBER;

   /***************************************************************************
   Función para validar el documento de identidad de Colombia

   Tipo de Documento ------------------- Tipo -------- Regla de validación - Tamaño -----
   33 - Cédula extranjería               Alfanumérico  Letras y números      Entre 3 y 15
   34 - Tarjeta de identidad             Numérico      Números               Entre 9 y 11
   35 - Registro civil de nacimiento     Alfanumérico  Letras y números      Entre 3 y 20
   36 - Cédula ciudadanía                Numérico      Números               Entre 3 y 10
   37 - NIT persona jurídica             Numérico      Números               9
            valor entre 800.000.000 y 999.999.999
   38 - Número único de identificación   Numérico      Números               10
        personal (NUIP)
            Valor >= 1.000.000.000
   39 - NIT persona natural              Numérico                            Entre 9 y 11
   40 - Pasaporte                        Alfanumérico  Letras y números      Entre 3 y 15
   *****************************************************************************/
   FUNCTION f_validar_nif_col(
      pctipide   IN   NUMBER,
      pnnumide   IN   VARCHAR,
      pcsexper   IN   NUMBER
   )
      RETURN NUMBER;

   /***************************************************************************
      Función para obtener el dígito de control del documento de identidad de Colombia
      Tipos de documento a los que puede aplicar calcular el dígito de control
      Tipo de Documento ------------------- Tipo -------- Regla de validación - Tamaño -----
      36 - Cédula ciudadanía                Numérico      Números               Entre 3 y 10
      *****************************************************************************/
   FUNCTION f_digito_nif_col(pctipide IN NUMBER, pnnumide IN VARCHAR)
      RETURN NUMBER;

-- Bug 24780 - ETM - 11/12/2012
   FUNCTION f_validar_nif_chile(pctipide IN NUMBER, pnnumide IN VARCHAR)
      RETURN NUMBER;

   FUNCTION f_digito_nif_chile(pctipide IN NUMBER, pnnumide IN VARCHAR)
      RETURN VARCHAR2;

--FIN  Bug 24780 - ETM - 11/12/2012

   -- BUG 0026968/0147424 - FAL - 27/06/2013
   FUNCTION f_validar_nif_chile_jurid(pctipide IN NUMBER, pnnumide IN VARCHAR)
      RETURN NUMBER;
-- FIN BUG 0026968/0147424
   FUNCTION f_validar_nif_malta(
      pctipide   IN   per_personas.ctipide%TYPE,
      pnnumide   IN   per_personas.nnumide%TYPE
   )
      RETURN NUMBER;

      FUNCTION f_validar_nif_ecu(pctipide IN NUMBER, pnnumide IN VARCHAR)
      RETURN NUMBER;
      /***************************************************************************
      Función para validar el documento de identidad de Ecuador
      Tipo de Documento ------------------- Tipo -------- Regla de validación - Tamaño -----

      36 - Cédula ciudadanía                Numérico      Números               10 o 13
      40 - Pasaporte                        Alfanumérico  Letras y números      Entre 3 y 15
      34 - RUC                              Numérico      Numeros               13
      35 - RUC Público                      Numérico      Numeros               13
      *****************************************************************************/
END pac_ide_persona;

/

  GRANT EXECUTE ON "AXIS"."PAC_IDE_PERSONA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IDE_PERSONA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IDE_PERSONA" TO "PROGRAMADORESCSI";
