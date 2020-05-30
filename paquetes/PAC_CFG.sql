--------------------------------------------------------
--  DDL for Package PAC_CFG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_CFG" AS
/******************************************************************************
   NOMBRE:       PAC_CFG
   PROPÓSITO: Recupera les diferents configuracions d'accions disponibles

    REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        ??/??/????   ???                Creación package
   2.0        13/03/2009   DCT                Creación Función F_GET_USER_CFGDOC
                                              Modificar: F_SET_CFG_DEFECTO
                                              Modificar: F_SET_CFG_USER
   3.0        05/05/2009   DRA                0009981: IAX - Baixar l'empresa a totes les taules del model CFG
   4.0        13/10/2010   XPL                16064: CRT101 - Boton enviar correo avisando de nueva solicitud
   5.0        26/10/2010   DRA                5. 0016471: CRT - Configuracion de visibilidad/contratacion de productos a nivel de perfil
   6.0        24/02/2011   ICV                6. 0017718: CCAT003 - Accés a productes en funció de l'operació
   7.0        07/03/2012   JMP                7. 21569: CRE998 - Configurar llençador d'Informes per perfil
   8.0        24/01/2013   MLA                10.25816: RSAG - Enviar un correo con datos adjuntos.
   9.0        03/08/2019   JMJRR              9. IAXIS-4994 Se modifican parametros de entrada y proceso de obtener informacion usuarios
******************************************************************************/

   /***********************************************************************
      Funció que donada un usuari, ha d'accedir a la taula CFG_USER i retornar pel paràmetre de sortida
       pcaccion la seva configuracció d'accions.
      param in pcuser  : código del usuario
            in pcempres: código de la empresa
      param out pcaccion : código de la accion
      return: devuelve 0 si todo bien, sino el código del error
   ***********************************************************************/
   FUNCTION f_get_user_cfgaccion(pcuser IN VARCHAR2, pcempres IN NUMBER, pcaccion OUT VARCHAR2)
      RETURN NUMBER;

   /***********************************************************************
     Funció que donat un usuari i una acció (i un producte opcionalment), retorna si l'usuari pot realitzar l'acció o no.
       Si pot realitzar l'acció, amb una determinada opció, es retorna l'opció en qüestió com a paràmetre de sortida.
     param in pcuser  : código del usuario
     param in pcaccion : código de la accion
     param in psproduc : código del producto
     param in pcempres : código de la empresa
     param out pcrealiza : código de la accion
     return: devuelve 0 si todo bien, sino el código del error
   ***********************************************************************/
   FUNCTION f_get_user_accion_permitida(
      pcuser IN VARCHAR2,
      pcaccion IN VARCHAR2,
      psproduc IN NUMBER,
      pcempres IN NUMBER,   -- BUG9981:DRA:06/05/2009
      pcrealiza OUT NUMBER)
      RETURN NUMBER;

   /******************************************************************************************
     Autor: CPM (07/11/2008)
     Descripción: Inserta un registro en la tabla CFG_USER.
     Parámetros entrada: - pcusuari -> usuario
                         - pwizard -> configuración de navegación
                         - pform -> configuración de formularios
                         - paccion -> configuración de acciones
                         - pcempres -> Empresa
                         - pccfgdoc -> configuración de documentos
     BUG0008898 - 16/03/2009 - DCT
     return:             devuelve 0 si todo bien, sino el código del error
   ******************************************************************************************/
   FUNCTION f_set_cfg_user(
      pcusuari IN VARCHAR2,
      pwizard IN VARCHAR2,
      pform IN VARCHAR2,
      paccion IN VARCHAR2,
      pcempres IN NUMBER,
      pccfgdoc IN VARCHAR2,
      pcaccprod IN VARCHAR2,   -- BUG16471:DRA:26/10/2010
      pccfgmap IN VARCHAR2,   -- BUG 21569 - 07/03/2012 - JMP  R
      pcrol IN VARCHAR2,
      pareas IN VARCHAR2) --IAXIS-4994
      RETURN NUMBER;

   /******************************************************************************************
     Autor: CPM (07/11/2008)
     Descripción: Inserta/Update un registro en la tabla MENU_USERCODIROL.
     Parámetros entrada: - pcusuari -> usuario
                         - pmenu -> configuración de navegación
     return:             devuelve 0 si todo bien, sino el código del error
   ******************************************************************************************/
   FUNCTION f_set_cfg_menu(pcusuari IN VARCHAR2, pmenu IN VARCHAR2)
      RETURN NUMBER;

   /******************************************************************************************
     Autor: XVILA (04/12/2008)
     Descripció: Retorna una llista dels perfils de suplements.
     Paràmetres entrada: -
     Paràmetres sortida  - psqlquery -> consulta construida
     return:             retorna 0 si va tot bé, sino el codi de l'error
   ******************************************************************************************/
   FUNCTION f_get_lst_codsuplem(psqlquery OUT VARCHAR2)
      RETURN NUMBER;

   /******************************************************************************************
     Autor: XVILA (04/12/2008)
     Descripció: Inserta els valors passats per paràmetre a la taula PDS_CONFIG_USER
     Paràmetres entrada: - pcuser    -> id. usuari
                         - pcconsupl -> id. conf dels suplements
     return:             retorna 0 si va tot bé, sino el codi de l'error
   ******************************************************************************************/
   FUNCTION f_set_pds_configuser(pcuser IN VARCHAR2, pcconsupl IN VARCHAR2)
      RETURN NUMBER;

   /******************************************************************************************
     Autor: JTS (02/10/2012)
     Descripció: Inserta els valors passats per paràmetre a la taula PSU_USUAGRU
     Paràmetres entrada: - pcuser    -> id. usuari
                         - pcusuagru -> id. conf
     return:             retorna 0 si tot va bé, sino el codi de l'error
   ******************************************************************************************/
   FUNCTION f_set_psu_usuagru(pcuser IN VARCHAR2, pcusuagru IN VARCHAR2)
      RETURN NUMBER;

   /******************************************************************************************
     Autor: XVILA (11/12/2008)
     Descripció: Inserta els valors passats per paràmetre a la taula PDS_CONFIG_USER
     Paràmetres entrada: - pcusuari -> id. usuari
                         - pcrolmen -> codi rol menu
     return:             retorna 0 si va tot bé, sino el codi de l'error
   ******************************************************************************************/
   FUNCTION f_set_dsiusurol(pcusuari IN VARCHAR2, pcrolmen IN VARCHAR2)
      RETURN NUMBER;

   /******************************************************************************************
     Autor: XVILA (11/12/2008)
     Descripció: Inserta els valors passats per paràmetre a la taula USU_DATOS
     Paràmetres entrada: - pcusuari -> id. usuari
     return:             retorna 0 si va tot bé, sino el codi de l'error
   ******************************************************************************************/
   FUNCTION f_set_usu_datos(pcusuari IN VARCHAR2)
      RETURN NUMBER;

   /******************************************************************************************
     Autor: XVILA (12/12/2008)
     Descripció: Configuració usuari
     Paràmetres entrada: - pcusuari  -> id. usuari
                         - pcempresa -> codi empresa
                         - pctipacc  -> codi tipus accés a l'aplicació
     return:             retorna 0 si va tot bé, sino el codi de l'error
   ******************************************************************************************/
   FUNCTION f_set_cfg_defecto(pcusuari IN VARCHAR2, pcempresa IN NUMBER, pctipacc IN NUMBER)
      RETURN NUMBER;

    /*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
       Autor: David Ciurans Tor (12/03/2009)
       Descripción: Recupera la configuración del documento associada a un usuario.
       Parámetros entrada: - pcuser    -> Usuario
                           - pcempres  -> Empresa
        Parámetros salida: - mensajes  -> Mensajes de error
       Retorno:            - vccfgdoc  -> Configuración de Documento asociada al usuario
                             NULL      -> Error
   ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
   FUNCTION f_get_user_cfgdoc(pcuser IN VARCHAR2, pcempres IN NUMBER, pccfgdoc OUT VARCHAR2)
      RETURN NUMBER;

   /************************************************************************************************
         Bug 16064: CRT101 - Boton enviar correo avisando de nueva solicitud #XPL#13/10/2010
         Descripción: Envia mail segons la taula de configuració
         Parámetros entrada: - pcempres --> Empresa
                               pmodo    --> Mode
                               ptevento --> Event del qual s'accedeix
                               psproduc --> Producte
                               psseguro --> Seguro si existia per pantalla
                               pnriesgo --> Risc del seguro
                               pnsinies --> Sinistre
                               pcmotmov --> Motiu moviment
                               pcidioma --> Idioma del context
         Retorno:            - error -> 1 KO, 0 OK
     ************************************************************************************************/
   FUNCTION f_enviar_notificacion(
      pcempres IN NUMBER,
      pmodo IN VARCHAR2,
      ptevento IN VARCHAR2,
      psproduc IN NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnsinies IN NUMBER,
      pcmotmov IN NUMBER,
      pcidioma IN NUMBER)
      RETURN NUMBER;

   -- BUG16471:DRA:26/10/2010:Inici
   /*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
       Descripción: Recupera la configuración del acceso a productos
       Parámetros entrada: - pcuser    -> Usuario
                           - pcempres  -> Empresa
        Parámetros salida: - mensajes  -> Mensajes de error
       Retorno:            - vcaccprod -> Configuración del acceso a productos
                             NULL      -> Error
   ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
   FUNCTION f_get_user_caccprod(pcuser IN VARCHAR2, pcempres IN NUMBER, pcaccprod OUT VARCHAR2)
      RETURN NUMBER;

   /*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
       Descripción: Recupera la configuración del acceso a productos
       Parámetros entrada: - pcuser    -> Usuario
                           - pcempres  -> Empresa
        Parámetros salida: - pcemitir  -> Contratación
                           - pcimprimir-> Impresion pólizas
                           - pcestudios-> Estudios
                           - pccartera -> Cartera
                           - pcrecibos -> Impresion recibos
       Retorno:            - num_err   -> Error
   ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
   FUNCTION f_get_caccprod(
      pcempres IN NUMBER,
      pcaccprod IN VARCHAR2,
      psproduc IN NUMBER,
      pcemitir OUT NUMBER,
      pcimprimir OUT NUMBER,
      pcestudios OUT NUMBER,
      pccartera OUT NUMBER,
      pcrecibos OUT NUMBER,
      paccesible OUT NUMBER)
      RETURN NUMBER;

-- BUG16471:DRA:26/10/2010:Fi

   /***********************************************************************
     F_NEW ROL Crea un nuevo rol
     return: devuelve 0 si todo bien, sino el código del error
   ***********************************************************************/
   FUNCTION f_new_rol(
      pcrol IN VARCHAR2,
      ptrol IN VARCHAR2,
      pcidioma IN NUMBER,
      pcempres IN NUMBER,
      pcwizard IN VARCHAR2,
      pcform IN VARCHAR2,
      pcaccion IN VARCHAR2,
      pcmenu IN VARCHAR2,
      pcconsupl IN VARCHAR2,
      pcdocumentacio IN VARCHAR2,
      pcaccprod IN VARCHAR2,
      pcmap IN VARCHAR2,
      pcusuagru IN VARCHAR2,
      pcilimite IN NUMBER)
      RETURN NUMBER;

   /***********************************************************************
     F_SET_ROL Updatea un rol
     return: devuelve 0 si todo bien, sino el código del error
   ***********************************************************************/
   FUNCTION f_set_rol(
      pcrol IN VARCHAR2,
      ptrol IN VARCHAR2,
      pcidioma IN NUMBER,
      pcempres IN NUMBER,
      pcwizard IN VARCHAR2,
      pcform IN VARCHAR2,
      pcaccion IN VARCHAR2,
      pcmenu IN VARCHAR2,
      pcconsupl IN VARCHAR2,
      pcdocumentacio IN VARCHAR2,
      pcaccprod IN VARCHAR2,
      pcmap IN VARCHAR2,
      pcusuagru IN VARCHAR2,
      pcilimite IN NUMBER)
      RETURN NUMBER;

   /***********************************************************************
  f_get_roles
  return:
***********************************************************************/
   FUNCTION f_get_roles(pcrol IN VARCHAR2, ptrol IN VARCHAR2)
      RETURN VARCHAR2;

   /***********************************************************************
  f_get_rol
  return:
***********************************************************************/
   FUNCTION f_get_rol(
      pcrol IN VARCHAR2,
      pcempres IN NUMBER,
      ptrol OUT VARCHAR2,
      pcwizard OUT VARCHAR2,
      pcform OUT VARCHAR2,
      pcaccion OUT VARCHAR2,
      pcmenu OUT VARCHAR2,
      pcconsupl OUT VARCHAR2,
      pcdocumentacio OUT VARCHAR2,
      pcaccprod OUT VARCHAR2,
      pcmap OUT VARCHAR2,
      pcusuagru OUT VARCHAR2,
      pcilimite OUT NUMBER)
      RETURN NUMBER;

   /************************************************************************************************
        Bug 10.0       24/01/2013   MLA                10.25816: RSAG - Enviar un correo con datos adjuntos.
        f_enviar_mail_adjunto
        Descripción: Envia un correo electronico con archivos adjustos segun tabla de configuración
        Parámetros entrada:
              pcempres IN NUMBER, Codigo de empresa
              pmodo IN VARCHAR2, Modo de envio  cfg_notificacion->cmodo
              ptevento IN VARCHAR2, Evento de envio  cfg_notificacion->tevento
              pcidioma IN NUMBER, Idioma de envio
              pdirectorio IN VARCHAR2, Listado separado por coma ',' con los nombres de los directorios donde
                                       se encuetran los documentos a enviar, son directory Oracle
              pdocumentos IN VARCHAR2, Listado separado por coma ',' con los nombres de archivos a enviar
              pmimestypes IN VARCHAR2, Listado separado por coma ',' con los mimetypes de los archivos a
                                       enviar, en el mismo orden de correlacion que en pdocumentos
              pdestinatarios IN VARCHAR2, Destinatarios a enviar
              psproduc IN VARCHAR2 DEFAULT '0' Producto asociado
        Retorno:      0 OK / Retorno <> 0 Error
    ************************************************************************************************/
   FUNCTION f_enviar_mail_adjunto(
      pcempres IN NUMBER,
      pmodo IN VARCHAR2,
      ptevento IN VARCHAR2,
      pcidioma IN NUMBER,
      pdirectorio IN VARCHAR2,
      pdocumentos IN VARCHAR2,
      pmimestypes IN VARCHAR2,
      pdestinatarios IN VARCHAR2,
      psproduc IN VARCHAR2 DEFAULT '0',
      psseguro IN NUMBER DEFAULT NULL)
      RETURN NUMBER;
END pac_cfg;

/

  GRANT EXECUTE ON "AXIS"."PAC_CFG" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_CFG" TO "PROGRAMADORESCSI";
  GRANT EXECUTE ON "AXIS"."PAC_CFG" TO "R_AXIS";
