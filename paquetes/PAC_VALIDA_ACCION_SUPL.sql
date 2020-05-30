--------------------------------------------------------
--  DDL for Package PAC_VALIDA_ACCION_SUPL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_VALIDA_ACCION_SUPL" AUTHID CURRENT_USER IS
    /******************************************************************************
      NOMBRE:      PAC_VALIDA_ACCION_SUPL
      PROPÓSITO:   Package con proposito de negocio para introducir funciones de
                   validación de lanzamiento del suplemento diferido. Estas
                   funciones de validación pretenden ser genericas para cada movimiento
                   de suplemento y se parametriza su llamada en la tabla
                   PDS_SUPL_DIF_CONFIG.FVALFUN

      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
      1.0        27/04/2009     RSC              1. Creación del package.
                                                    Bug 9905 - Suplemento de cambio de forma de pago diferido
      2.0        06/11/2012     MDS              2. 0024278: LCOL_T010 - Suplementos diferidos - Cartera - colectivos
   ******************************************************************************/

   /***********************************************************************
      Realiza la validación de que la forma de pago no esté ya modificada al
      valor que pretende modificar el diferimiento, en cuyo caso, no se deberá
      realiza el suplemento diferido de cambio de forma de pago.

      param in psseguro  : Identificador de seguro.
      param in pfecha    : Fecha de suplemento diferido.
      param in pcmotmov  : Identificador de motivo de movimiento de suplemento.
      return             : Number 1 --> SI debe realizar el suplemento,
                                  0 --> NO debe realizar el suplemento
                                 -1 --> Error
   ***********************************************************************/-- Bug 9905 - 27/04/2009 - RSC - Suplemento de cambio de forma de pago diferido
   FUNCTION f_valida_cforpag(psseguro IN NUMBER, pfecha IN DATE, pcmotmov IN NUMBER)
      RETURN NUMBER;

   -- Fin Bug 9905

   /***********************************************************************
      Realiza la validación de que la modificación de garantías no esté ya
      modificada al valor que pretende modificar el diferimiento, en cuyo
      caso, no se deberá realiza el suplemento diferido de modificación de
      garantías.

      param in psseguro  : Identificador de seguro.
      param in pfecha    : Fecha de suplemento diferido.
      param in pcmotmov  : Identificador de motivo de movimiento de suplemento.
      return             : Number 1 --> SI debe realizar el suplemento,
                                  0 --> NO debe realizar el suplemento
                                 -1 --> Error
   ***********************************************************************/
    -- Bug 9905 - 27/04/2009 - RSC - Suplemento de cambio de forma de pago diferido
   FUNCTION f_valida_garantias(psseguro IN NUMBER, pfecha IN DATE, pcmotmov IN NUMBER)
      RETURN NUMBER;

   -- Fin Bug 9905

   /***********************************************************************
      Realiza la validación de que la modificación de revalorización no esté
      ya modificada al valor que pretende modificar el diferimiento, en cuyo
      caso, no se deberá realiza el suplemento diferido de modificación de
      revalorización.

      param in psseguro  : Identificador de seguro.
      param in pfecha    : Fecha de suplemento diferido.
      param in pcmotmov  : Identificador de motivo de movimiento de suplemento.
      return             : Number 1 --> SI debe realizar el suplemento,
                                  0 --> NO debe realizar el suplemento
                                 -1 --> Error
   ***********************************************************************/
    -- Bug 9905 - 27/04/2009 - RSC - Suplemento de cambio de forma de pago diferido
   FUNCTION f_valida_revali(psseguro IN NUMBER, pfecha IN DATE, pcmotmov IN NUMBER)
      RETURN NUMBER;

   -- Fin Bug 9905

   /***********************************************************************
      Realiza la validación de que la modificación de agente no esté ya modificada
      al valor que pretende modificar el diferimiento, en cuyo caso, no se deberá
      realiza el suplemento diferido de modificación de agente.

      param in psseguro  : Identificador de seguro.
      param in pfecha    : Fecha de suplemento diferido.
      param in pcmotmov  : Identificador de motivo de movimiento de suplemento.
      return             : Number 1 --> SI debe realizar el suplemento,
                                  0 --> NO debe realizar el suplemento
                                 -1 --> Error
   ***********************************************************************/
    -- Bug 9905 - 27/04/2009 - RSC - Suplemento de cambio de forma de pago diferido
   FUNCTION f_valida_agente(psseguro IN NUMBER, pfecha IN DATE, pcmotmov IN NUMBER)
      RETURN NUMBER;

-- Fin Bug 9905

   -- Ini Bug 24278 - MDS - 07/11/2012
   /***********************************************************************
      Realiza la validación de que la modificación de domicilio del tomador no esté ya modificada
      al valor que pretende modificar el diferimiento, en cuyo caso, no se deberá
      realizar el suplemento diferido de modificación de domicilio del tomador.

      param in psseguro  : Identificador de seguro.
      param in pfecha    : Fecha de suplemento diferido.
      param in pcmotmov  : Identificador de motivo de movimiento de suplemento.
      return             : Number 1 --> SI debe realizar el suplemento
                                  0 --> NO debe realizar el suplemento
                                 -1 --> Error
   ***********************************************************************/
   FUNCTION f_valida_cdomici(psseguro IN NUMBER, pfecha IN DATE, pcmotmov IN NUMBER)
      RETURN NUMBER;

   /***********************************************************************
      Realiza la validación de que el cambio de revalorización no esté ya hecho
      al valor que pretende modificar el diferimiento, en cuyo caso, no se deberá
      realizar el suplemento diferido de cambio de revalorización.

      param in psseguro  : Identificador de seguro.
      param in pfecha    : Fecha de suplemento diferido.
      param in pcmotmov  : Identificador de motivo de movimiento de suplemento.
      return             : Number 1 --> SI debe realizar el suplemento
                                  0 --> NO debe realizar el suplemento
                                 -1 --> Error
   ***********************************************************************/
   FUNCTION f_valida_revaloriza(psseguro IN NUMBER, pfecha IN DATE, pcmotmov IN NUMBER)
      RETURN NUMBER;

   /***********************************************************************
      Realiza la validación de que la modificación del porcentaje de participación no esté ya modificada
      al valor que pretende modificar el diferimiento, en cuyo caso, no se deberá
      realizar el suplemento diferido de modificación del porcentaje de participación.

      param in psseguro  : Identificador de seguro.
      param in pfecha    : Fecha de suplemento diferido.
      param in pcmotmov  : Identificador de motivo de movimiento de suplemento.
      return             : Number 1 --> SI debe realizar el suplemento
                                  0 --> NO debe realizar el suplemento
                                 -1 --> Error
   ***********************************************************************/
   FUNCTION f_valida_modifcocorretaje(psseguro IN NUMBER, pfecha IN DATE, pcmotmov IN NUMBER)
      RETURN NUMBER;

   /***********************************************************************
      Realiza la validación de que la modificación de garantías no esté ya modificada
      al valor que pretende modificar el diferimiento, en cuyo caso, no se deberá
      realizar el suplemento diferido de modificación de garantías.

      param in psseguro  : Identificador de seguro.
      param in pfecha    : Fecha de suplemento diferido.
      param in pcmotmov  : Identificador de motivo de movimiento de suplemento.
      return             : Number 1 --> SI debe realizar el suplemento
                                  0 --> NO debe realizar el suplemento
                                 -1 --> Error
   ***********************************************************************/
   FUNCTION f_valida_modifgarantias(psseguro IN NUMBER, pfecha IN DATE, pcmotmov IN NUMBER)
      RETURN NUMBER;

   /***********************************************************************
      Realiza la validación de que la modificación de cláusulas no esté ya modificada
      al valor que pretende modificar el diferimiento, en cuyo caso, no se deberá
      realizar el suplemento diferido de modificación de garantías.

      param in psseguro  : Identificador de seguro.
      param in pfecha    : Fecha de suplemento diferido.
      param in pcmotmov  : Identificador de motivo de movimiento de suplemento.
      return             : Number 1 --> SI debe realizar el suplemento
                                  0 --> NO debe realizar el suplemento
                                 -1 --> Error
   ***********************************************************************/
   FUNCTION f_valida_modifclausulas(psseguro IN NUMBER, pfecha IN DATE, pcmotmov IN NUMBER)
      RETURN NUMBER;

   /***********************************************************************
      Realiza la validación de que la modificación de preguntas de póliza no esté ya modificada
      al valor que pretende modificar el diferimiento, en cuyo caso, no se deberá
      realizar el suplemento diferido de modificación de preguntas de póliza.

      param in psseguro  : Identificador de seguro.
      param in pfecha    : Fecha de suplemento diferido.
      param in pcmotmov  : Identificador de motivo de movimiento de suplemento.
      return             : Number 1 --> SI debe realizar el suplemento
                                  0 --> NO debe realizar el suplemento
                                 -1 --> Error
   ***********************************************************************/
   FUNCTION f_valida_modifpregunpol(psseguro IN NUMBER, pfecha IN DATE, pcmotmov IN NUMBER)
      RETURN NUMBER;

   /***********************************************************************
      Realiza la validación de que la modificación de preguntas de riesgo no esté ya modificada
      al valor que pretende modificar el diferimiento, en cuyo caso, no se deberá
      realizar el suplemento diferido de modificación de preguntas de póliza.

      param in psseguro  : Identificador de seguro.
      param in pfecha    : Fecha de suplemento diferido.
      param in pcmotmov  : Identificador de motivo de movimiento de suplemento.
      return             : Number 1 --> SI debe realizar el suplemento
                                  0 --> NO debe realizar el suplemento
                                 -1 --> Error
   ***********************************************************************/
   FUNCTION f_valida_modifpregunries(psseguro IN NUMBER, pfecha IN DATE, pcmotmov IN NUMBER)
      RETURN NUMBER;

-- Fin Bug 24278 - MDS - 07/11/2012

   /***********************************************************************
      Realiza la validación de que la modificación de oficina no esté ya modificada
      al valor que pretende modificar el diferimiento, en cuyo caso, no se deberá
      realizar el suplemento diferido de modificación de preguntas de póliza.

      param in psseguro  : Identificador de seguro.
      param in pfecha    : Fecha de suplemento diferido.
      param in pcmotmov  : Identificador de motivo de movimiento de suplemento.
      return             : Number 1 --> SI debe realizar el suplemento
                                  0 --> NO debe realizar el suplemento
                                 -1 --> Error
   ***********************************************************************/
   FUNCTION f_valida_modifoficina(psseguro IN NUMBER, pfecha IN DATE, pcmotmov IN NUMBER)
      RETURN NUMBER;

   /***********************************************************************
      Realiza la validación de que la modificación de forma de pago no esté ya modificada
      al valor que pretende modificar el diferimiento, en cuyo caso, no se deberá
      realizar el suplemento diferido de modificación de forma de pago de póliza.

      param in psseguro  : Identificador de seguro.
      param in pfecha    : Fecha de suplemento diferido.
      param in pcmotmov  : Identificador de motivo de movimiento de suplemento.
      return             : Number 1 --> SI debe realizar el suplemento
                                  0 --> NO debe realizar el suplemento
                                 -1 --> Error
   ***********************************************************************/
   FUNCTION f_valida_modifcforpag(psseguro IN NUMBER, pfecha IN DATE, pcmotmov IN NUMBER)
      RETURN NUMBER;

   /***********************************************************************
      Realiza la validación de que la modificación de la fecha de efecto no esté ya modificada
      al valor que pretende modificar el diferimiento, en cuyo caso, no se deberá
      realizar el suplemento diferido de modificación de fecha de efecto de póliza.

      param in psseguro  : Identificador de seguro.
      param in pfecha    : Fecha de suplemento diferido.
      param in pcmotmov  : Identificador de motivo de movimiento de suplemento.
      return             : Number 1 --> SI debe realizar el suplemento
                                  0 --> NO debe realizar el suplemento
                                 -1 --> Error
   ***********************************************************************/
   FUNCTION f_valida_modiffefecto(psseguro IN NUMBER, pfecha IN DATE, pcmotmov IN NUMBER)
      RETURN NUMBER;

   /***********************************************************************
      Realiza la validación de que la modificación de la comision no esté ya modificada
      al valor que pretende modificar el diferimiento, en cuyo caso, no se deberá
      realizar el suplemento diferido de modificación de comision de póliza.

      param in psseguro  : Identificador de seguro.
      param in pfecha    : Fecha de suplemento diferido.
      param in pcmotmov  : Identificador de motivo de movimiento de suplemento.
      return             : Number 1 --> SI debe realizar el suplemento
                                  0 --> NO debe realizar el suplemento
                                 -1 --> Error
   ***********************************************************************/
   FUNCTION f_valida_modifcomisi(psseguro IN NUMBER, pfecha IN DATE, pcmotmov IN NUMBER)
      RETURN NUMBER;

   /***********************************************************************
       Realiza la validación de que la modificación del retorno no esté ya modificada
       al valor que pretende modificar el diferimiento, en cuyo caso, no se deberá
       realizar el suplemento diferido de modificación del retorno de póliza.

       param in psseguro  : Identificador de seguro.
       param in pfecha    : Fecha de suplemento diferido.
       param in pcmotmov  : Identificador de motivo de movimiento de suplemento.
       return             : Number 1 --> SI debe realizar el suplemento
                                   0 --> NO debe realizar el suplemento
                                  -1 --> Error
    ***********************************************************************/
   FUNCTION f_valida_modifretorno(psseguro IN NUMBER, pfecha IN DATE, pcmotmov IN NUMBER)
      RETURN NUMBER;

   /***********************************************************************
       Realiza la validación de que la modificación del coaseguro no esté ya modificada
       al valor que pretende modificar el diferimiento, en cuyo caso, no se deberá
       realizar el suplemento diferido de modificación del coaseguro de póliza.

       param in psseguro  : Identificador de seguro.
       param in pfecha    : Fecha de suplemento diferido.
       param in pcmotmov  : Identificador de motivo de movimiento de suplemento.
       return             : Number 1 --> SI debe realizar el suplemento
                                   0 --> NO debe realizar el suplemento
                                  -1 --> Error
    ***********************************************************************/
   FUNCTION f_valida_modifcoacua(psseguro IN NUMBER, pfecha IN DATE, pcmotmov IN NUMBER)
      RETURN NUMBER;

   /***********************************************************************
      Realiza la validación de que la modificación de prorroga vigencia no esté ya modificada
      al valor que pretende modificar el diferimiento, en cuyo caso, no se deberá
      realizar el suplemento diferido de prorroga vigencia.

      param in psseguro  : Identificador de seguro.
      param in pfecha    : Fecha de suplemento diferido.
      param in pcmotmov  : Identificador de motivo de movimiento de suplemento.
      return             : Number 1 --> SI debe realizar el suplemento
                                  0 --> NO debe realizar el suplemento
                                 -1 --> Error
      BUG 0026070 - 20/02/2013 - JMF
   ***********************************************************************/
   FUNCTION f_prorroga_vigencia(psseguro IN NUMBER, pfecha IN DATE, pcmotmov IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_valida_alta_garantias(psseguro IN NUMBER, pfecha IN DATE, pcmotmov IN NUMBER)
      RETURN NUMBER;
END pac_valida_accion_supl;

/

  GRANT EXECUTE ON "AXIS"."PAC_VALIDA_ACCION_SUPL" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_VALIDA_ACCION_SUPL" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_VALIDA_ACCION_SUPL" TO "PROGRAMADORESCSI";
