--------------------------------------------------------
--  DDL for Package Body PAC_MD_SINI_GRABARDATOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MD_SINI_GRABARDATOS" AS
/******************************************************************************
   NOMBRE:     PAC_MD_SINI_GRABARDATOS
   PROPÓSITO:  Funciones para la gestión de siniestros (Grabar objetos a base de datos)

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        02/01/2008   JAS                1. Creación del package.
******************************************************************************/

    e_object_error  exception;
    e_param_error   exception;

    /***********************************************************************
       Graba los datos de una valoración.
       param in  pnsinies   : Número de siniestro
       param in  pcgarant   : Garantía que se está valorando
       param in  fvalora    : Fecha de la valoración
       param in  ivalora    : Importe de la valoración
       param out mensajes   : T_IAX_MENSAJES con los posibles mensajes de error
       return               : 0 -> Inserción realizada correctament
                              1 -> Error
    ***********************************************************************/
    FUNCTION F_Ins_Valorasini (
        pnsinies    IN      NUMBER,
        pcgarant    IN      NUMBER,
        pfvalora    IN      DATE,
        pivalora    IN      NUMBER,
        mensajes    IN OUT  T_IAX_MENSAJES
    )
    RETURN NUMBER IS

        vobjectname         VARCHAR2(500) := 'PAC_MD_SINI_GRABARDATOS.F_Ins_Valorasini';
        vparam              VARCHAR2(500) := 'parámetros - pnsinies: '||pnsinies||' - pcgarant: '||pcgarant||' - pfvalora: '||pfvalora||' - pivalora: '||pivalora;
        vpasexec            NUMBER (5)              := 1;
        vnumerr             NUMBER (8)              := 0;

    BEGIN

        --Comprovació de paràmetres d'entrada
        IF pnsinies IS NULL OR pcgarant IS NULL OR pfvalora IS NULL OR pivalora IS NULL THEN
            RAISE e_param_error;
        END IF;

        vpasexec := 3;

        INSERT INTO valorasini (nsinies,  cgarant,  fvalora,  ivalora, cusualt, falta)
                        VALUES (pnsinies, pcgarant, pfvalora, pivalora, f_user, f_sysdate);

        vnumerr := pac_sin.f_mantdiario_valora (pnsinies, 0, pcgarant, 1);
        IF vnumerr <> 0 THEN
            vpasexec := 5;
            PAC_IOBJ_MENSAJES.Crea_Nuevo_Mensaje(mensajes,1,vnumerr);
            RAISE e_object_error;
        END IF;

        RETURN vnumerr;

    EXCEPTION
        WHEN e_param_error THEN
            PAC_IOBJ_MENSAJES.P_TratarMensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
            RETURN 1;
        WHEN e_object_error THEN
            PAC_IOBJ_MENSAJES.P_TratarMensaje(mensajes, vobjectname, 1000006, vpasexec, vparam, vnumerr);
            RETURN 1;
        WHEN OTHERS THEN
            PAC_IOBJ_MENSAJES.P_TratarMensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
            RETURN 1;
    END F_Ins_Valorasini;


    /***********************************************************************
       Graba en la base de datos, los datos del siniestro guardado en la variable global del paquete
       param out pObSini   : Objeto con la información del siniestro que se debe dar de alta.
       param out onsinies  : número de siniestro asignado en el alta de siniestro
       param out mensajes  : mensajes de error
       return              : 1 -> Todo correcto
                             0 -> Se ha producido un error
    ***********************************************************************/
	FUNCTION F_AltaSiniestro (
        pObSini     IN      OB_IAX_SINIESTROS,
        onsinies    OUT     NUMBER,
        mensajes    IN OUT  T_IAX_MENSAJES
    )
    RETURN NUMBER IS

        vobjectname     VARCHAR2(500) := 'PAC_MD_SINI_GRABARDATOS.F_Alta_Siniestro';
        vparam          VARCHAR2(500)  := 'parámetros - pObSini';
        vpasexec        NUMBER (5)              := 1;
        vnumerr         NUMBER (8)              := 0;

        vnsinies        NUMBER;
        vfsinies        DATE;
        vtmsg           VARCHAR2 (1000);
        vntramit        NUMBER;

    BEGIN

        --Comprovació dels parámetres d'entrada
        IF  pObSini IS NULL
         OR pObSini.sseguro IS NULL
         OR pObSini.nriesgo IS NULL
         OR pObSini.tsinies IS NULL
        THEN
            RAISE e_param_error;
        END IF;

        if pObSini.fsinies is null then
          PAC_IOBJ_MENSAJES.Crea_Nuevo_Mensaje(mensajes, 1, 9000640);
          RETURN 1;
        end if;

        if pObSini.fnotifi is null then
          PAC_IOBJ_MENSAJES.Crea_Nuevo_Mensaje(mensajes, 1, 9000641);
          RETURN 1;
        end if;

        if pObSini.ccausin is null then
          PAC_IOBJ_MENSAJES.Crea_Nuevo_Mensaje(mensajes, 1, 9000637);
          RETURN 1;
        end if;

        if pObSini.cmotsin is null then
          PAC_IOBJ_MENSAJES.Crea_Nuevo_Mensaje(mensajes, 1, 9000638);
          RETURN 1;
        end if;

        if pObSini.garantias is null or pObSini.garantias.count = 0 then
          PAC_IOBJ_MENSAJES.Crea_Nuevo_Mensaje(mensajes, 1, 9000639);
          RETURN 1;
        end if;

        --Concatenació de la data i hora d'ocurrència del sinistre.
        vfsinies := TO_DATE(TO_CHAR(pObSini.fsinies,'dd/mm/yyyy')||NVL(pObSini.hsinies,'00:00')||':00','dd/mm/yyyy hh24:mi:ss');

        vpasexec:= 2;

        --Obertura ràpida del sinistre
        vnumerr := pac_sin.f_inicializar_siniestro (pObSini.sseguro,
                                                    pObSini.nriesgo,
                                                    vfsinies,
                                                    pObSini.fnotifi,
                                                    pObSini.tsinies,
                                                    pObSini.ccausin,
                                                    pObSini.cmotsin,
                                                    NULL,
                                                    vnsinies,
                                                    NULL);
        vpasexec := 3;
        IF vnumerr <> 0 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes,1,vnumerr);
            RAISE e_object_error;
        END IF;

        vpasexec := 4;

        --Enregistrar culpabilitat del sinistre.
        vnumerr := pac_sin.f_constar_culpabilidad (vnsinies,pObSini.cculpab);
        IF vnumerr <> 0 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes,1,vnumerr);
            RAISE e_object_error;
        END IF;

        vpasexec := 5;

        --Enregistrar valoracions de sinistres.
        FOR i IN pObSini.garantias.first..pObSini.garantias.last LOOP
            vpasexec := 6;
            vnumerr := pac_md_sini_grabardatos.f_ins_valorasini (vnsinies,
                                                                pObSini.garantias(i).cgarant,
                                                                pObSini.garantias(i).fvalora,
                                                                pObSini.garantias(i).ivalora,
                                                                mensajes);
            IF vnumerr <> 0 THEN
                pac_iobj_mensajes.crea_nuevo_mensaje(mensajes,1,vnumerr);
                RAISE e_object_error;
            END IF;
        END LOOP;

        onsinies := vnsinies;

        RETURN 0;

    EXCEPTION
        WHEN e_param_error THEN
            PAC_IOBJ_MENSAJES.P_TratarMensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
            RETURN 1;
        WHEN e_object_error THEN
            PAC_IOBJ_MENSAJES.P_TratarMensaje(mensajes, vobjectname, 1000006, vpasexec, vparam, vnumerr);
            RETURN 1;
        WHEN OTHERS THEN
            PAC_IOBJ_MENSAJES.P_TratarMensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
            RETURN 1;
    END F_AltaSiniestro;

END PAC_MD_SINI_GRABARDATOS;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_SINI_GRABARDATOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_SINI_GRABARDATOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_SINI_GRABARDATOS" TO "PROGRAMADORESCSI";
