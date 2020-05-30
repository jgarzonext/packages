--------------------------------------------------------
--  DDL for Package Body PAC_CFG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_CFG" AS
/******************************************************************************
   NOMBRE:    PAC_CFG
   PROPÓSITO: Recupera les diferents configuracions d'accions disponibles

    REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0
   2.0        13/03/2009   DCT                Creación Función F_GET_USER_CFGDOC
                                               Modificar: F_SET_CFG_DEFECTO
                                               Modificar: F_SET_CFG_USER
   3.0        06/05/2009   DRA                0009981: IAX - Baixar l'empresa a totes les taules del model CFG
   4.0        09/06/2009   ETM                0010259: IAX - Crear l'històric d'usuaris --QUITAMOS EL DELETE, INSERT YA QUE HACIA QUE EL TRIGGER NO SE EJECUTARA
   5.0        13/10/2010   XPL                16064: CRT101 - Boton enviar correo avisando de nueva solicitud
   6.0        26/10/2010   DRA                6. 0016471: CRT - Configuracion de visibilidad/contratacion de productos a nivel de perfil
   7.0        22/11/2010   DRA                7. 0016666: CRT - Modificaciones VISITA TOLEDO 10-11 noviembre 2010
   8.0        24/02/2011   ICV                8. 0017718: CCAT003 - Accés a productes en funció de l'operació
   9.0        07/03/2012   JMP                9. 21569: CRE998 - Configurar llençador d'Informes per perfil
   10.0       24/01/2013   MAL                10.25816: RSAG - Enviar un correo con datos adjuntos.
   11.0       22/10/2013   FAC               11. 28627: Agregar al mantenimiento de Usuario la asignación de nivel de psu
   12.0        22/10/2013   FAC               12. 28627: Agregar al mantenimiento de Usuario la asignación de nivel de psu
   13.0       14/03/2014   JLTS               13. 30417_0169644_QT-0011827: Se cambia el literal 104631 (Error al leer de la tabla USUARIOS) por 9906626 (Error de validación)
   14.0       03/08/2019   JMJRR              14. IAXIS-4994 Se modifican parametros de entrada y proceso de obtener informacion usuarios
******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   /***********************************************************************
      Funció que donada un usuari, ha d'accedir a la taula CFG_USER i retornar pel paràmetre de sortida
       pcaccion la seva configuracció d'accions.
      param in pcuser  : código del usuario
            in pcempres: código de la empresa
      param out pcaccion : código de la accion
      return: devuelve 0 si todo bien, sino el código del error
   ***********************************************************************/
   FUNCTION f_get_user_cfgaccion(pcuser IN VARCHAR2, pcempres IN NUMBER, pcaccion OUT VARCHAR2)
      RETURN NUMBER IS
   BEGIN
      SELECT ccfgacc
        INTO pcaccion
        FROM cfg_user
       WHERE UPPER(cuser) = UPPER(pcuser)
         AND cempres = pcempres;   -- BUG9981:DRA:06/05/2009

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_CFG', 1,
                     'f_get_user_cfgaccion. Error .  CUSER = ' || pcuser || ' cempres = '
                     || pcempres,
                     SQLERRM);
         RETURN 9000504;
   --Error al recuperar la configuració de l'acció de l'usuari
   END f_get_user_cfgaccion;

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
      RETURN NUMBER IS
      vsproduc       NUMBER;
   BEGIN
      IF pcuser IS NULL
         OR pcaccion IS NULL THEN
         RETURN 9000505;   -- Faltan parametros
      END IF;

      vsproduc := NVL(psproduc, 0);

      -- BUG9981:DRA:06/05/2009:Inici
      BEGIN
         SELECT a.crealiza
           INTO pcrealiza
           FROM cfg_accion a, cfg_user u
          WHERE UPPER(u.cuser) = UPPER(pcuser)
            AND u.cempres = pcempres   -- BUG9981:DRA:06/05/2009
            AND a.cempres = u.cempres
            AND a.ccfgacc = u.ccfgacc
            AND a.caccion = pcaccion
            AND a.sproduc = vsproduc;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            BEGIN
               SELECT a.crealiza
                 INTO pcrealiza
                 FROM cfg_accion a, cfg_user u
                WHERE UPPER(u.cuser) = UPPER(pcuser)
                  AND u.cempres = pcempres   -- BUG9981:DRA:06/05/2009
                  AND a.cempres = u.cempres
                  AND a.ccfgacc = u.ccfgacc
                  AND a.caccion = pcaccion
                  AND a.sproduc = 0;   -- para todos los productos
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  RETURN 0;
            END;
      END;

      -- BUG9981:DRA:06/05/2009:Fi
      RETURN 1;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_CFG', 1,
                     'f_get_user_accion_permitida. Error. CUSER = ' || pcuser || ' CACCION = '
                     || pcaccion || ' SPRODUC = ' || psproduc || ' CEMPRES = ' || pcempres,
                     SQLERRM);
         RETURN 9000504;
   --Error al recuperar la configuració de l'acció de l'usuari
   END f_get_user_accion_permitida;

   /******************************************************************************************
     Autor: CPM (07/11/2008)
     Descripción: Inserta/Update un registro en la tabla CFG_USER.
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
      pccfgmap IN VARCHAR2,   -- BUG 21569 - 07/03/2012 - JMP
      pcrol IN VARCHAR2,
      pareas IN VARCHAR2) --IAXIS-4994
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_CFG.f_set_cfg_user';
      vparam         VARCHAR2(500)
         := 'parámetros - pcusuari: ' || pcusuari || ' pwizard:' || pwizard || ' pform:'
            || pform || ' paccion:' || paccion || '   pcempres:' || pcempres || ' pccfgdoc:'
            || pccfgdoc || ' pcaccprod:' || pcaccprod || ' pccfgmap: ' || pccfgmap;
      vpasexec       NUMBER(5) := 1;
      vcount         NUMBER;
   BEGIN
      --Comprovació dels parámetres d'entrada
      IF pcusuari IS NULL
         OR pwizard IS NULL
         OR pform IS NULL
         OR paccion IS NULL
         OR pcempres IS NULL THEN
         RAISE e_param_error;
      END IF;

      BEGIN
         INSERT INTO cfg_user
                     (cuser, cempres, ccfgwiz, ccfgform, ccfgacc, ccfgdoc,
                      caccprod, ccfgmap, crol)   -- BUG16471:DRA:26/10/2010
              VALUES (UPPER(pcusuari), pcempres, pwizard, pform, paccion, pccfgdoc,
                      pcaccprod, pccfgmap, pcrol);   -- BUG16471:DRA:26/10/2010
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            SELECT COUNT(1)
              INTO vcount
              FROM cfg_user
             WHERE ccfgwiz = pwizard
               AND ccfgform = pform
               AND ccfgacc = paccion
               AND ccfgdoc = pccfgdoc
               AND caccprod = pcaccprod   -- BUG16471:DRA:26/10/2010
               AND UPPER(cuser) = UPPER(pcusuari)
               AND cempres = pcempres   -- BUG9981:DRA:06/05/2009
               AND crol = pcrol
               AND ccfgmarca = pareas;--IAXIS-4994

            IF vcount = 0 THEN
               UPDATE cfg_user
                  SET ccfgwiz = pwizard,
                      ccfgform = pform,
                      ccfgacc = paccion,
                      ccfgdoc = pccfgdoc,
                      caccprod = pcaccprod,   -- BUG16471:DRA:26/10/2010
                      ccfgmap = pccfgmap,
                      crol = pcrol,
                      ccfgmarca = pareas --IAXIS-4994
                WHERE UPPER(cuser) = UPPER(pcusuari)
                  AND cempres = pcempres;   -- BUG9981:DRA:06/05/2009;
            END IF;
      END;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'Objeto invocado con parámetros erroneos');
         RETURN 9000505;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 9906626;
   END f_set_cfg_user;

   /******************************************************************************************
     Autor: CPM (07/11/2008)
     Descripción: Inserta/Update un registro en la tabla MENU_USERCODIROL.
     Parámetros entrada: - pcusuari -> usuario
                         - pmenu -> configuración de navegación
     return:             devuelve 0 si todo bien, sino el código del error
   ******************************************************************************************/
   FUNCTION f_set_cfg_menu(pcusuari IN VARCHAR2, pmenu IN VARCHAR2)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_CFG.f_set_cfg_menu';
      vparam         VARCHAR2(500)
                                := 'parámetros - pcusuari: ' || pcusuari || ' pmenu:' || pmenu;
      vpasexec       NUMBER(5) := 1;
      vcount         NUMBER;
   BEGIN
      -- Para una primera version solo permitimos un rol por usuario
      --Comprovació dels parámetres d'entrada
      IF pcusuari IS NULL
         OR pmenu IS NULL THEN
         RAISE e_param_error;
      END IF;

      -- ETM  BUG--010259: IAX--INI
      SELECT COUNT(1)
        INTO vcount
        FROM menu_usercodirol
       WHERE UPPER(cuser) = UPPER(pcusuari);

      IF vcount <> 0 THEN
         UPDATE menu_usercodirol
            SET crolmen = pmenu
          WHERE UPPER(cuser) = UPPER(pcusuari);
      ELSE
         INSERT INTO menu_usercodirol
                     (cuser, crolmen, cusualt, falta)
              VALUES (UPPER(pcusuari), pmenu, f_user, f_sysdate);
      END IF;

      -- ETM  BUG--010259: IAX--FIN
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'Objeto invocado con parámetros erroneos');
         RETURN 9000505;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 9906626;
   END f_set_cfg_menu;

   /******************************************************************************************
     Autor: XVILA (04/12/2008)
     Descripció: Retorna una llista dels perfils de suplements.
     Paràmetres entrada: -
     Paràmetres sortida  - psqlquery -> consulta construida
     return:             retorna 0 si tot va bé, sino el codi de l'error
   ******************************************************************************************/
   FUNCTION f_get_lst_codsuplem(psqlquery OUT VARCHAR2)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_CFG.f_get_lst_codsuplem';
      vparam         VARCHAR2(500) := 'parámetros - null';
      vpasexec       NUMBER(5) := 1;
   BEGIN
      psqlquery := 'SELECT CCONSUPL, TCONSUPL FROM PDS_COD_SUPLEM';
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 9000658;
   END f_get_lst_codsuplem;

   /******************************************************************************************
     Autor: XVILA (04/12/2008)
     Descripció: Inserta els valors passats per paràmetre a la taula PDS_CONFIG_USER
     Paràmetres entrada: - pcuser    -> id. usuari
                         - pcconsupl -> id. conf dels suplements
     return:             retorna 0 si tot va bé, sino el codi de l'error
   ******************************************************************************************/
   FUNCTION f_set_pds_configuser(pcuser IN VARCHAR2, pcconsupl IN VARCHAR2)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_CFG.f_set_pds_configuser';
      vparam         VARCHAR2(500)
                        := 'parámetros - pcuser: ' || pcuser || ' -- pcconsupl: ' || pcconsupl;
      vpasexec       NUMBER(5) := 1;
   BEGIN
      --Comprovació dels parámetres d'entrada
      IF pcuser IS NULL THEN
         RAISE e_param_error;
      END IF;

      BEGIN
         INSERT INTO pds_config_user
                     (cuser, cconsupl)
              VALUES (UPPER(pcuser), pcconsupl);
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            vpasexec := 2;

            UPDATE pds_config_user
               SET cconsupl = pcconsupl
             WHERE UPPER(cuser) = UPPER(pcuser);
      END;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'Objeto invocado con parámetros erroneos');
         RETURN 9000505;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 9000659;
   END f_set_pds_configuser;

   /******************************************************************************************
     Autor: JTS (02/10/2012)
     Descripció: Inserta els valors passats per paràmetre a la taula PSU_USUAGRU
     Paràmetres entrada: - pcuser    -> id. usuari
                         - pcusuagru -> id. conf
     return:             retorna 0 si tot va bé, sino el codi de l'error
   ******************************************************************************************/
   FUNCTION f_set_psu_usuagru(pcuser IN VARCHAR2, pcusuagru IN VARCHAR2)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_CFG.f_set_psu_usuagru';
      vparam         VARCHAR2(500)
                        := 'parámetros - pcuser: ' || pcuser || ' -- pcusuagru: ' || pcusuagru;
      vpasexec       NUMBER(5) := 1;
   BEGIN
      --Comprovació dels parámetres d'entrada
      IF pcuser IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF pcusuagru IS NULL THEN
         DELETE FROM psu_usuagru
               WHERE UPPER(cusuari) = UPPER(pcuser);
      ELSE
         BEGIN
            INSERT INTO psu_usuagru
                        (cusuari, cusuagru)
                 VALUES (UPPER(pcuser), pcusuagru);
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               vpasexec := 2;

               UPDATE psu_usuagru
                  SET cusuagru = pcusuagru
                WHERE UPPER(cusuari) = UPPER(pcuser);
         END;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'Objeto invocado con parámetros erroneos');
         RETURN 9000505;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 9000659;
   END f_set_psu_usuagru;

   /******************************************************************************************
     Autor: XVILA (11/12/2008)
     Descripció: Inserta els valors passats per paràmetre a la taula DSIUSUROL
     Paràmetres entrada: - pcusuari -> id. usuari
                         - pcrolmen -> codi rol menu
     return:             retorna 0 si va tot bé, sino el codi de l'error
   ******************************************************************************************/
   FUNCTION f_set_dsiusurol(pcusuari IN VARCHAR2, pcrolmen IN VARCHAR2)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_CFG.f_set_dsiusurol';
      vparam         VARCHAR2(500)
                      := 'parámetros - pcusuari: ' || pcusuari || ' -- pcrolmen: ' || pcrolmen;
      vpasexec       NUMBER(5) := 1;
   BEGIN
      --Comprovació dels parámetres d'entrada
      IF pcusuari IS NULL
         OR pcrolmen IS NULL THEN
         RAISE e_param_error;
      END IF;

      BEGIN
         INSERT INTO dsiusurol
                     (crolmen, cusuari, cusualt, falta)
              VALUES (pcrolmen, UPPER(pcusuari), f_user, f_sysdate);
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            vpasexec := 2;

            UPDATE dsiusurol
               SET crolmen = pcrolmen
             WHERE cusuari = pcusuari;
      END;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'Objeto invocado con parámetros erroneos');
         RETURN 9000505;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 9000663;   --Error al insertar en la taula DSIUSUROL
   END f_set_dsiusurol;

   /******************************************************************************************
     Autor: XVILA (11/12/2008)
     Descripció: Inserta els valors passats per paràmetre a la taula USU_DATOS
     Paràmetres entrada: - pcusuari -> id. usuari
     return:             retorna 0 si va tot bé, sino el codi de l'error
   ******************************************************************************************/
   FUNCTION f_set_usu_datos(pcusuari IN VARCHAR2)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_CFG.f_set_usu_datos';
      vparam         VARCHAR2(500) := 'parámetros - pcusuari: ' || pcusuari;
      vpasexec       NUMBER(5) := 1;
   BEGIN
      --Comprovació dels parámetres d'entrada
      IF pcusuari IS NULL THEN
         RAISE e_param_error;
      END IF;

      BEGIN
         INSERT INTO usu_datos
                     (cusuari,
                      tinicia, nportal, cactivo,
                      fcadpassw)
              VALUES (UPPER(pcusuari),
                      SUBSTR(UPPER(pcusuari), 1, 2) || SUBSTR(UPPER(pcusuari), -2), 0, 'S',
                      TO_DATE('01/01/2027', 'dd/mm/yyyy'));
      END;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'Objeto invocado con parámetros erroneos');
         RETURN 9000505;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 9000665;   --Error al insertar en la tabla USU_DATOS
   END f_set_usu_datos;

   /******************************************************************************************
     Autor: XVILA (12/12/2008)
     Descripció: Configuració usuari
     Paràmetres entrada: - pcusuari  -> id. usuari
                         - pcempresa -> codi empresa
                         - pctipacc  -> codi tipus accés a l'aplicació
     return:             retorna 0 si va tot bé, sino el codi de l'error
   ******************************************************************************************/
   FUNCTION f_set_cfg_defecto(pcusuari IN VARCHAR2, pcempresa IN NUMBER, pctipacc IN NUMBER)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_CFG.f_set_cfg_defecto';
      vparam         VARCHAR2(500)
         := 'parámetros - pcusuari: ' || pcusuari || ' -- pcempresa: ' || pcempresa
            || ' -- pctipacc: ' || pctipacc;
      vpasexec       NUMBER(5) := 1;
      vnum_err       NUMBER(8);

      CURSOR user_def IS
         SELECT cempres, ctipacc, crolmen, ccfgform, ccfgwiz, ccfgacc, cconsupl, cdsirol,
                ccfgdoc, caccprod, ccfgmap, crol, ccfgmarca   -- BUG16471:DRA:26/10/2010 --IAXIS-4994
           FROM cfg_user_def
          WHERE ctipacc = pctipacc
            AND cempres = pcempresa;
   BEGIN
      --Comprovació dels parámetres d'entrada
      IF pcusuari IS NULL
         OR pcempresa IS NULL
         OR pctipacc IS NULL THEN
         RAISE e_param_error;
      END IF;

      FOR reg IN user_def LOOP
         vnum_err := pac_cfg.f_set_cfg_user(pcusuari, reg.ccfgwiz, reg.ccfgform, reg.ccfgacc,
                                            reg.cempres, reg.ccfgdoc, reg.caccprod,
                                            reg.ccfgmap, reg.crol, reg.ccfgmarca);   -- BUG16471:DRA:26/10/2010 --IAXIS-4994

         IF vnum_err <> 0 THEN
            RAISE e_object_error;
         END IF;

         vpasexec := 2;
         vnum_err := pac_cfg.f_set_cfg_menu(pcusuari, reg.crolmen);

         IF vnum_err <> 0 THEN
            RAISE e_object_error;
         END IF;

         vpasexec := 3;
         vnum_err := pac_cfg.f_set_pds_configuser(pcusuari, reg.cconsupl);

         IF vnum_err <> 0 THEN
            RAISE e_object_error;
         END IF;

         vpasexec := 4;
         vnum_err := pac_cfg.f_set_dsiusurol(pcusuari, reg.cdsirol);

         IF vnum_err <> 0 THEN
            RAISE e_object_error;
         END IF;

         vpasexec := 5;
         vnum_err := pac_cfg.f_set_usu_datos(pcusuari);

         IF vnum_err <> 0 THEN
            RAISE e_object_error;
         END IF;
      END LOOP;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'Objeto invocado con parámetros erroneos');
         RETURN 9000505;
      WHEN e_object_error THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'vnum_err: ' || vnum_err);
         RETURN vnum_err;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 111449;
   END f_set_cfg_defecto;

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
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_CFG.f_get_user_cfgdoc';
      vparam         VARCHAR2(500)
                           := 'parámetros - pcuser: ' || pcuser || ' - pcempres: ' || pcempres;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vccfgdoc       VARCHAR2(50);
   BEGIN
      --Comprovació de paràmetres d'entrada
      IF pcuser IS NULL
         OR pcempres IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;

      --Recupero la configuració específica del document de l'usuari.
      SELECT cu.ccfgdoc
        INTO pccfgdoc
        FROM cfg_user cu
       WHERE cu.cuser = pcuser
         AND cu.cempres = pcempres;

      --Tot ok
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'Objeto invocado con parámetros erroneos');
         RETURN 9000505;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 9001254;
   --Error al recuperar la configuració del document de l´usuari
   END f_get_user_cfgdoc;

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
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_cfg.f_enviar_notificacion';
      vparam         VARCHAR2(500)
         := 'parámetros - pcempres: ' || pcempres || ' - pmodo: ' || pmodo || ' - ptevento: '
            || ptevento || ' - psproduc: ' || psproduc || ' - psseguro: ' || psseguro
            || ' - pnriesgo: ' || pnriesgo || ' - pnsinies: ' || pnsinies || ' - pcmotmov: '
            || pcmotmov || ' - pcidioma: ' || pcidioma;
      vpasexec       NUMBER(5) := 1;
      num_err        NUMBER := 151909;
      vcempres       NUMBER;
      vmodo          VARCHAR2(200);
      vtevento       VARCHAR2(200);
      vsproduc       NUMBER;
      vmail          VARCHAR2(2000);
      vasunto        VARCHAR2(2000);
      vfrom          VARCHAR2(2000);
      vto            VARCHAR2(2000);
      vto2           VARCHAR2(2000);
      verror         VARCHAR2(2000);
      vscorreo       NUMBER;
      vquants        NUMBER;
   BEGIN
      vmodo := pmodo;

      IF pmodo IS NULL THEN
         vmodo := 'GENERAL';
      END IF;

      vtevento := ptevento;

      IF ptevento IS NULL THEN
         vtevento := 'GENERAL';
      END IF;

      SELECT COUNT(1)
        INTO vquants
        FROM cfg_notificacion
       WHERE cempres = pcempres
         AND cmodo = vmodo
         AND tevento = vtevento
         AND sproduc = psproduc;

      IF psproduc IS NULL
         OR vquants = 0 THEN
         --Si el producte no ve informat, o no té configuració específica, recuperem la parametrització independent de producte.
         vsproduc := 0;
      END IF;

      SELECT scorreo
        INTO vscorreo
        FROM cfg_notificacion
       WHERE cempres = pcempres
         AND cmodo = vmodo
         AND tevento = vtevento
         AND sproduc = vsproduc;

      num_err := pac_correo.f_mail(vscorreo, psseguro, pnriesgo, pcidioma, NULL, vmail,
                                   vasunto, vfrom, vto, vto2, verror, pnsinies, pcmotmov);

      BEGIN
         --Inserción en la tabla de LOG, aunque haya
         --habido error al enviar el correo
         INSERT INTO log_correo
                     (seqlogcorreo, fevento, cmailrecep, asunto, error, coficina, cterm,
                      cusuenvio)
              VALUES (seqlogcorreo.NEXTVAL, f_sysdate, vto, vasunto, verror, NULL, NULL,
                      f_user);
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 103869;   --Error al insertar en la tabla
      END;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN num_err;
   END f_enviar_notificacion;

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
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_CFG.f_get_user_caccprod';
      vparam         VARCHAR2(500)
                           := 'parámetros - pcuser: ' || pcuser || ' - pcempres: ' || pcempres;
      vpasexec       NUMBER(5) := 1;
      vcaccprod      VARCHAR2(50);
   BEGIN
      --Comprovació de paràmetres d'entrada
      IF pcuser IS NULL
         OR pcempres IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;

      --Recupero la configuració específica del accés de l'usuari.
      BEGIN
         SELECT cu.caccprod
           INTO pcaccprod
           FROM cfg_user cu
          WHERE cu.cuser = pcuser
            AND cu.cempres = pcempres;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            -- Si no lo encuentra puede que sea porque no se estan cruzando bien el usuario i la empresa,
            --  así que lo comentamos para que no colapse la TAB_ERROR
            pcaccprod := NULL;
      END;

      --Tot ok
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'Objeto invocado con parámetros erroneos');
         RETURN 9000505;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 9001254;
   --Error al recuperar la configuració del acceso a productes
   END f_get_user_caccprod;

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
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_CFG.f_get_caccprod';
      vparam         VARCHAR2(500)
         := 'parámetros - pcaccprod: ' || pcaccprod || ' - pcempres: ' || pcempres
            || ' - psproduc: ' || psproduc;
      vpasexec       NUMBER(5) := 1;
      v_valordef     NUMBER(1);
   BEGIN
      --Comprovació de paràmetres d'entrada
      IF pcempres IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;

      --Recupero la configuració específica del accés de l'usuari.
      BEGIN
         SELECT ap.cemitir, ap.cimprimir, ap.cestudios, ap.ccartera, ap.crecibos,
                ap.caccesible
           INTO pcemitir, pcimprimir, pcestudios, pccartera, pcrecibos,
                paccesible
           FROM cfg_acceso_producto ap
          WHERE ap.cempres = pcempres
            AND ap.caccprod = pcaccprod
            AND ap.sproduc = NVL(psproduc, 0);
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            vpasexec := 3;

            BEGIN
               SELECT ap.cemitir, ap.cimprimir, ap.cestudios, ap.ccartera, ap.crecibos,
                      ap.caccesible
                 INTO pcemitir, pcimprimir, pcestudios, pccartera, pcrecibos,
                      paccesible
                 FROM cfg_acceso_producto ap
                WHERE ap.cempres = pcempres
                  AND ap.caccprod = pcaccprod
                  AND ap.sproduc = 0;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  vpasexec := 4;
                  v_valordef := NVL(pac_parametros.f_parempresa_n(pcempres,
                                                                  'ACCESO_PRODUCTOS'),
                                    1);
                  pcemitir := v_valordef;
                  pcimprimir := v_valordef;
                  pcestudios := v_valordef;
                  pccartera := v_valordef;
                  pcrecibos := v_valordef;
                  paccesible := v_valordef;
            END;
      END;

      --Tot ok
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'Objeto invocado con parámetros erroneos');
         RETURN 9000505;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 9001254;
   --Error al recuperar la configuració del acceso a productes
   END f_get_caccprod;

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
      RETURN NUMBER IS
   BEGIN
      IF pcrol IS NULL
         OR ptrol IS NULL
         OR pcidioma IS NULL
         OR pcempres IS NULL
         OR pcwizard IS NULL
         OR pcform IS NULL
         OR pcaccion IS NULL THEN
         RETURN 9000505;   -- Faltan parametros
      END IF;

      BEGIN
         INSERT INTO cfg_rol
                     (crol, cempres, ccfgwiz, ccfgform, ccfgacc, crolmen, cconsupl,
                      ccfgdoc, caccprod, ccfgmap, cusuagru, ilimite)
              VALUES (pcrol, pcempres, pcwizard, pcform, pcaccion, pcmenu, pcconsupl,
                      pcdocumentacio, pcaccprod, pcmap, pcusuagru, pcilimite);
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            RETURN 9904284;
      END;

      BEGIN
         DELETE      cfg_rol_det
               WHERE crol = pcrol
                 AND cempres = pcempres;

         INSERT INTO cfg_rol_det
                     (crol, trol, cidioma, cempres)
            SELECT pcrol, ptrol, i.cidioma, pcempres
              FROM idiomas i;
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            RETURN 9904284;
      END;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_CFG', 1, 'f_new_rol. Error', SQLERRM);
         RETURN 9904283;
   END f_new_rol;

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
      RETURN NUMBER IS
   BEGIN
      IF pcrol IS NULL
         OR ptrol IS NULL
         OR pcidioma IS NULL
         OR pcempres IS NULL
         OR pcwizard IS NULL
         OR pcform IS NULL
         OR pcaccion IS NULL THEN
         RETURN 9000505;   -- Faltan parametros
      END IF;

      UPDATE cfg_rol
         SET ccfgwiz = pcwizard,
             ccfgform = pcform,
             ccfgacc = pcaccion,
             crolmen = pcmenu,
             cconsupl = pcconsupl,
             ccfgdoc = pcdocumentacio,
             caccprod = pcaccprod,
             ccfgmap = pcmap,
             cusuagru = pcusuagru,
             ilimite = pcilimite
       WHERE crol = pcrol
         AND cempres = pcempres;

      UPDATE cfg_rol_det
         SET trol = ptrol
       WHERE crol = pcrol
         AND cempres = pcempres
         AND cidioma = pcidioma;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_CFG', 1, 'f_set_rol. Error', SQLERRM);
         RETURN 9904283;
   END f_set_rol;

/***********************************************************************
  f_get_roles
  return:
***********************************************************************/
   FUNCTION f_get_roles(pcrol IN VARCHAR2, ptrol IN VARCHAR2)
      RETURN VARCHAR2 IS
      vsquery        VARCHAR2(500);
   BEGIN
      vsquery :=
         ' SELECT crol, trol, cempres
  FROM cfg_rol_det
 WHERE cidioma = pac_md_common.f_get_cxtidioma
   AND cempres = pac_md_common.f_get_cxtempresa ';

      IF pcrol IS NOT NULL THEN
         vsquery := vsquery || ' and lower(crol) like lower(''%' || pcrol || '%'') ';
      END IF;

      IF ptrol IS NOT NULL THEN
         vsquery := vsquery || ' and lower(trol) like lower(''%' || ptrol || '%'') ';
      END IF;

      RETURN vsquery;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_CFG', 1, 'f_get_roles. Error', SQLERRM);
         RETURN NULL;
   END f_get_roles;

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
      RETURN NUMBER IS
   BEGIN
      SELECT crd.trol, ccfgwiz, ccfgform, ccfgacc, crolmen, cconsupl, ccfgdoc, caccprod,
             ccfgmap, cusuagru, ilimite
        INTO ptrol, pcwizard, pcform, pcaccion, pcmenu, pcconsupl, pcdocumentacio, pcaccprod,
             pcmap, pcusuagru, pcilimite
        FROM cfg_rol cf, cfg_rol_det crd
       WHERE cf.crol = crd.crol
         AND cf.cempres = crd.cempres
         AND crd.cidioma = pac_md_common.f_get_cxtidioma
         AND cf.cempres = pcempres
         AND cf.crol = pcrol;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_CFG', 1, 'f_get_rol. Error', SQLERRM);
         RETURN 9904148;
   END f_get_rol;

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
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_cfg.f_enviar_mail_adjunto';
      vparam         VARCHAR2(500)
         := ' pcempres: ' || pcempres || ' pmodo: ' || pmodo || ' ptevento: ' || ptevento
            || ' pcidioma: ' || pcidioma || ' pdirectorio: ' || pdirectorio
            || ' pdocumentos: ' || pdocumentos || ' pmimestypes: ' || pmimestypes
            || ' pdestinatarios: ' || pdestinatarios || ' psproduc: ' || psproduc;
      vpasexec       NUMBER(5) := 1;
      num_err        NUMBER := 151909;
      vcempres       NUMBER;
      vmodo          VARCHAR2(200);
      vtevento       VARCHAR2(200);
      vsproduc       NUMBER;
      vmail          VARCHAR2(2000);
      vasunto        VARCHAR2(2000);
      vfrom          VARCHAR2(2000);
      vctipo         NUMBER;
      vto            VARCHAR2(2000);
      vto2           VARCHAR2(2000);
      verror         VARCHAR2(2000);
      vscorreo       NUMBER;
      vquants        NUMBER;
      vsecuen        NUMBER;
      vcont          NUMBER := 0;
      pos            NUMBER;
      pos2           NUMBER;
      np             VARCHAR2(10);
      nombre         VARCHAR2(180);
      vesfinal       BOOLEAN;
      vconn          UTL_SMTP.connection;
      PRAGMA AUTONOMOUS_TRANSACTION;

      TYPE rstring IS RECORD(
         cadena         VARCHAR2(500)
      );

      TYPE tstring IS TABLE OF rstring
         INDEX BY BINARY_INTEGER;

      vtdocumentos   tstring;
      vtmimestypes   tstring;
      vtdirectorios  tstring;

      FUNCTION f_strsplit(pcadena VARCHAR2, pseparador VARCHAR2)
         RETURN tstring IS
         vstart_pos     NUMBER := 1;
         vend_pos       NUMBER := 1;
         vcadena        VARCHAR2(3000);
         vcont          NUMBER := 0;
         vttstring      tstring;
      BEGIN
         vcadena := pcadena;
         vstart_pos := 1;

         IF pcadena = '' THEN
            RETURN vttstring;
         END IF;

         LOOP
            vend_pos := INSTR(vcadena, pseparador, vstart_pos);
            vcont := vcont + 1;

            IF vend_pos <> 0 THEN
               vttstring(vcont).cadena := SUBSTR(vcadena, vstart_pos, vend_pos - vstart_pos);
            ELSE
               vttstring(vcont).cadena := SUBSTR(vcadena, vstart_pos);
            END IF;

            EXIT WHEN vend_pos = 0;
            vstart_pos := vend_pos + 1;
         END LOOP;

         RETURN vttstring;
      END f_strsplit;

      FUNCTION f_converthtml(cadena VARCHAR2)
         RETURN VARCHAR2 IS
         caracter       VARCHAR2(1);
         resultado      VARCHAR2(3000);
      BEGIN
         FOR x IN 1 .. LENGTH(cadena) LOOP
            caracter := SUBSTR(cadena, x, 1);

            IF ASCII(caracter) >= 160 THEN
               resultado := resultado || CHR(38) || '#' || ASCII(caracter) || ';';
            ELSE
               resultado := resultado || caracter;
            END IF;
         END LOOP;

         RETURN resultado;
      END f_converthtml;
   BEGIN
      vpasexec := 1;
      vmodo := pmodo;

      IF pmodo IS NULL THEN
         vmodo := 'GENERAL';
      END IF;

      vtevento := ptevento;

      IF ptevento IS NULL THEN
         vtevento := 'GENERAL';
      END IF;

      vpasexec := 2;

      SELECT COUNT(1)
        INTO vquants
        FROM cfg_notificacion
       WHERE cempres = pcempres
         AND cmodo = vmodo
         AND tevento = vtevento
         AND sproduc = psproduc;

      IF psproduc IS NULL
         OR vquants = 0 THEN
         --Si el producte no ve informat, o no té configuració específica, recuperem la parametrització independent de producte.
         vsproduc := 0;
      END IF;

      vpasexec := 3;

--Cargamos la configuracion de correo
      SELECT scorreo
        INTO vscorreo
        FROM cfg_notificacion
       WHERE cempres = pcempres
         AND cmodo = vmodo
         AND tevento = vtevento
         AND sproduc = vsproduc;

      vpasexec := 4;

      --Cargamos el remitente y el tipo
      SELECT remitente, ctipo
        INTO vfrom, vctipo
        FROM mensajes_correo
       WHERE scorreo = vscorreo;

      vpasexec := 5;

      --Cargamos los destinatarios
      IF pdestinatarios IS NULL THEN
         SELECT destinatario || ' <' || direccion || '>'
           INTO vto
           FROM destinatarios_correo
          WHERE scorreo = vscorreo;
      ELSE
         vto := pdestinatarios;
      END IF;

      vpasexec := 6;

      SELECT msg.asunto, msg.cuerpo
        INTO vasunto, vmail
        FROM desmensaje_correo msg
       WHERE scorreo = vscorreo
         AND cidioma = pcidioma;

      vpasexec := 61;

      IF vscorreo = 54 THEN
         vpasexec := 663;
         np := psseguro;

         SELECT INITCAP(MAX(d.tnombre) || ' ' || MAX(d.tapelli1) || ' ' || MAX(d.tapelli2))
                                                                                       tomador
           INTO nombre
           FROM per_detper d, esttomadores t, estseguros s
          WHERE t.sperson = d.sperson
            AND s.sseguro = psseguro
            AND t.sseguro = s.sseguro;
      ELSE
         vpasexec := 664;

         SELECT npoliza
           INTO np
           FROM seguros
          WHERE sseguro = psseguro;

         SELECT INITCAP(MAX(d.tnombre) || ' ' || MAX(d.tapelli1) || ' ' || MAX(d.tapelli2))
                                                                                       tomador
           INTO nombre
           FROM per_detper d, tomadores t, seguros s
          WHERE t.sperson = d.sperson
            AND s.sseguro = psseguro
            AND t.sseguro = s.sseguro;
      END IF;

      vpasexec := 665;
      --sustitución de los npolizas en asunto
      pos := INSTR(vmail, '#NPOLIZA#', 1);
      vpasexec := 63;

      IF pos > 0 THEN
         vmail := REPLACE(vmail, '#NPOLIZA#', np);
      END IF;

      vpasexec := 64;
      --sustitución de los nsimulacion en asunto
      pos := INSTR(vmail, '#NSIMULA#', 1);
      vpasexec := 63;

      IF pos > 0 THEN
         vmail := REPLACE(vmail, '#NSIMULA#', np);
      END IF;

      vpasexec := 644;
      --buscar y concatenar nombre apellidos de tomador
      vpasexec := 65;
      --sustitución de los nombre de tomador de los mails
      pos := INSTR(vmail, '#NOMBRETOMADOR#', 1);
      vpasexec := 66;

      IF pos > 0 THEN
         vmail := REPLACE(vmail, '#NOMBRETOMADOR#', nombre);
      END IF;

      p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam, 'Coreo: ' || vmail);
      vpasexec := 7;
      vconn := pac_send_mail.begin_mail(sender => vfrom, recipients => vto,
                                        subject => f_converthtml(vasunto),
                                        mime_type => pac_send_mail.multipart_mime_type);
      vpasexec := 8;
      pac_send_mail.attach_text(conn => vconn, DATA => f_converthtml(vmail),
                                mime_type => 'text/html');
      vpasexec := 9;
      vtdocumentos := f_strsplit(pdocumentos, ',');
      vpasexec := 10;
      vtmimestypes := f_strsplit(pmimestypes, ',');
      vpasexec := 101;
      vtdirectorios := f_strsplit(pdirectorio, ',');
      vpasexec := 11;

      FOR i IN vtdocumentos.FIRST .. vtdocumentos.LAST LOOP
         vesfinal :=(i = vtdocumentos.LAST);
         pac_send_mail.attach_base64_readfile(conn => vconn,
                                              DIRECTORY => vtdirectorios(i).cadena,
                                              filename => vtdocumentos(i).cadena,
                                              mime_type => vtmimestypes(i).cadena,
                                              inline => FALSE, LAST => vesfinal);
      END LOOP;

      vpasexec := 12;
      pac_send_mail.end_mail(conn => vconn);
      vpasexec := 13;

      DECLARE
      BEGIN
         --Inserción en la tabla de LOG, aunque haya
         --habido error al enviar el correo
         SELECT seqlogcorreo.NEXTVAL
           INTO vsecuen
           FROM DUAL;

         INSERT INTO log_correo
                     (seqlogcorreo, fevento, cmailrecep, asunto, error, coficina, cterm,
                      cusuenvio, sseguro)
              VALUES (vsecuen, f_sysdate, vto, vasunto, verror, NULL, NULL,
                      f_user, psseguro);

         vcont := 0;

         FOR i IN vtdocumentos.FIRST .. vtdocumentos.LAST LOOP
            vcont := vcont + 1;

            INSERT INTO log_adjunto_correo
                        (seqlogcorreo, iddoc, ndocumento, ndirectorio,
                         cmimetype)
                 VALUES (vsecuen, vcont, vtdocumentos(i).cadena, vtdirectorios(i).cadena,
                         vtmimestypes(i).cadena);
         END LOOP;

         COMMIT;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 103869;   --Error al insertar en la tabla
      END;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN num_err;
   END f_enviar_mail_adjunto;
END pac_cfg;

/

  GRANT EXECUTE ON "AXIS"."PAC_CFG" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_CFG" TO "PROGRAMADORESCSI";
  GRANT EXECUTE ON "AXIS"."PAC_CFG" TO "R_AXIS";
