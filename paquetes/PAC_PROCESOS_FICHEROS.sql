--------------------------------------------------------
--  DDL for Package PAC_PROCESOS_FICHEROS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_PROCESOS_FICHEROS" IS
   /*************************************************************************
      PROCEDURE p_tip_docum
      Permite obtener el tipo de documento con la codificacion de la
      Superfinanciera.
      param out p_tip_docum      : Tipo de documento que saldra en el fichero
      return                   :
   *************************************************************************/
   PROCEDURE p_tip_docum(p_tip_docum OUT VARCHAR2);

   /*************************************************************************
      PROCEDURE p_obtiene_signo
      Permite obtener el signo de los valores numericos que se procesen
      param out p_signo      : Signo + o -, dependiendo del valor que
                               se este procesando
      return                 :
   *************************************************************************/
   PROCEDURE p_obtiene_signo(p_signo OUT VARCHAR2);

   /*************************************************************************
      PROCEDURE p_obtiene_valor
      Permite obtener el valor que saldra en el fichero, cuando es numerico
      se obtiene el valor absoluto y se formatea con una longitud de 17 y
      rellenado con ceros; si es texto, se formatea con longitud de 50 y
      rellenado con espacios.
      param out p_valor      : valor formateado que sale en el fichero
      return                   :
   *************************************************************************/
   PROCEDURE p_obtiene_valor(p_valor OUT VARCHAR2);

   PROCEDURE p_obtiene_valor_x_tipo(p_valor OUT VARCHAR2);

   /*************************************************************************
      PROCEDURE p_obtiene_valor
      Permite obtener el valor que saldra en el fichero, cuando es numerico
      se obtiene el valor absoluto y se formatea con una longitud de 17 y
      rellenado con ceros; si es texto, se formatea con longitud de 50 y
      rellenado con espacios.
      param out p_valor      : valor formateado que sale en el fichero
      return                   :
   *************************************************************************/
   PROCEDURE p_obtiene_valor003(p_valor OUT VARCHAR2);

   /*************************************************************************
      PROCEDURE p_obtiene_orden_ben
      Permite obtener el orden de los beneficiarios segun su importancia segun su posible permanencia en la renta
      param in p_sseguro      : sequencia del seguro
      param in p_sproduc      : sequencia del producto
      param in p_nriesgo      : numero de riesgo
      param in p_nmovimi      : numero de movimiento
      param in p_ffin         : fecha fin
      param in p_numben       : numero del beneficiario a segun prioridad
      return  sequencia de la persona seun la prioridad solicitada                 :
   *************************************************************************/
   FUNCTION f_obtiene_orden_ben(
      p_sseguro NUMBER,
      p_sproduc NUMBER,
      p_nriesgo NUMBER,
      p_nmovimi NUMBER,
      p_ffin DATE,
      p_numben NUMBER)
      RETURN NUMBER;

      /*************************************************************************
      PROCEDURE f_obtiene_numero_meses
      Permite obtener el numero de meses no informados en el check de validacion
      param in p_nmesextra     : numero de meses extra
      param in p_imesextra     : importes de meses extra
      return  numero de meses adicionales                :
   *************************************************************************/
   FUNCTION f_obtiene_numero_meses(p_nmesextra IN VARCHAR, p_imesextra IN VARCHAR)
      RETURN NUMBER;

      /*************************************************************************
      PROCEDURE f_obtiene_numero_hijos
      Obtienen el numero de hijos validos o invalidos segun el orden de los beneficiarios segun su importancia segun su posible permanencia en la renta
      param in p_sseguro      : sequencia del seguro
      param in p_sproduc      : sequencia del producto
      param in p_nriesgo      : numero de riesgo
      param in p_nmovimi      : numero de movimiento
      param in p_ffin         : fecha fin
      param in p_valido       : 1 hijos validos, 2 hijos invalidos
      return  numero de hijos segun la prioridad solicitada                 :
   *************************************************************************/
   FUNCTION f_obtiene_numero_hijos(
      p_sseguro NUMBER,
      p_sproduc NUMBER,
      p_nriesgo NUMBER,
      p_nmovimi NUMBER,
      p_ffin DATE,
      p_valido NUMBER)
      RETURN NUMBER;
END pac_procesos_ficheros;

/

  GRANT EXECUTE ON "AXIS"."PAC_PROCESOS_FICHEROS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_PROCESOS_FICHEROS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_PROCESOS_FICHEROS" TO "PROGRAMADORESCSI";
