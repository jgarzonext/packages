--------------------------------------------------------
--  DDL for Package PAC_MNTCAMPANYAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_MNTCAMPANYAS" IS
/******************************************************************************
    NOMBRE:      PAC_MNTCAMPANYAS
    PROPÓSITO:   Funciones para la gestión de campañas

    REVISIONES:
    Ver        Fecha        Autor             Descripción
    ---------  ----------  ---------  ------------------------------------
    1.0        08/05/2013   AMC       1. Creación del package. Bug 26615/143210
******************************************************************************/

   /**********************************************************************************************
      Función para recuperar campañas
      param in pccampanya: codigo campaña
      param in ptcampanya: descripción de campaña

      Bug 26615/143210 - 08/05/2013 - AMC
   ************************************************************************************************/
   FUNCTION f_get_campanyas(
      pccampanya IN NUMBER,   -- codigo campaña
      ptcampanya IN VARCHAR2,   -- Deripción de la campaña
      pcidioma IN NUMBER)
      RETURN VARCHAR2;

   /**********************************************************************************************
        Función para recuperar campanyas
        param in pccampanya:    codigo campaña
        param in ptodo: Recupera todos los idiomas o solo los informados

        Bug 26615/143210 - 08/05/2013 - AMC
     ************************************************************************************************/
   FUNCTION f_get_campanya(pccampanya IN NUMBER,   -- codigo campaña
                                                ptodo IN NUMBER)
      RETURN VARCHAR2;

    /**********************************************************************************************
      Función para guardar campanyas
      param in pccampanya:    codigo campaña
      param in ptcampanya:    descripción de campaña
      param in pcidioma: código de idioma

      Bug 26615/143210 - 08/05/2013 - AMC
   ************************************************************************************************/
   FUNCTION f_set_campanya(
      pccampanya IN NUMBER,   -- codigo campaña
      ptcampanya IN VARCHAR2,   -- Deripción de la campaña
      pcidioma IN NUMBER)
      RETURN NUMBER;

     /**********************************************************************************************
       Función para borrar campanyas
       param in pccampanya:    codigo campaña

       Bug 26615/143210 - 08/05/2013 - AMC
   ************************************************************************************************/
   FUNCTION f_del_campanya(pccampanya IN NUMBER   -- codigo campaña
                                               )
      RETURN NUMBER;

     /**********************************************************************************************
       Función para borrar una descriccion de la campanya
       param in pccampanya:    codigo campaña
       param in pcidioma: código de idioma

       Bug 26615/143210 - 08/05/2013 - AMC
   ************************************************************************************************/
   FUNCTION f_del_campanya_lin(pccampanya IN NUMBER,   -- codigo campaña
                                                    pcidioma IN NUMBER)
      RETURN NUMBER;
END pac_mntcampanyas;

/

  GRANT EXECUTE ON "AXIS"."PAC_MNTCAMPANYAS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MNTCAMPANYAS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MNTCAMPANYAS" TO "PROGRAMADORESCSI";
