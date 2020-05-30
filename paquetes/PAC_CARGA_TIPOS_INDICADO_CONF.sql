--------------------------------------------------------
--  DDL for Package PAC_CARGA_TIPOS_INDICADO_CONF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_CARGA_TIPOS_INDICADO_CONF" IS
   --
   /***************************************************************************
      PROCEDURE p_asigna_user
      Procedimiento que asigna usuario de carga
         param in  puser:     Descripción del usuario.
   ***************************************************************************/
   PROCEDURE p_asigna_user(puser VARCHAR2);
   /**************************************************************************
      PROCEDURE p_borra_tipos_indicadores
      Procedimiento que borra los registros grabados en MIG_TIPOS_INDICADORES y relacionados, en iAxis
   ***************************************************************************/
   PROCEDURE p_borra_tipos_indicadores;
   --
   /***************************************************************************
      PROCEDURE p_carga_indica
      Procedimiento que ejecuta el cargue de un fichero particular
         param in  ptab_des:     Descripción de la tabla.
   ***************************************************************************/
   PROCEDURE p_carga_indica(ptab_des VARCHAR2);
   --
END pac_carga_tipos_indicado_conf;

/

  GRANT EXECUTE ON "AXIS"."PAC_CARGA_TIPOS_INDICADO_CONF" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_CARGA_TIPOS_INDICADO_CONF" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_CARGA_TIPOS_INDICADO_CONF" TO "PROGRAMADORESCSI";
