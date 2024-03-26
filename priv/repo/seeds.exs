######################################
# Script for populating the database #
######################################

alias Prepair.Repo
alias Prepair.Accounts
alias Prepair.Auth.ApiKey
alias Prepair.Notifications.NotificationTemplate
alias Prepair.Products.Category
alias Prepair.Products.Manufacturer
alias Prepair.Products.Product
alias Prepair.Products.Part
alias Prepair.Profiles.Ownership

##
## Create users
##

{:ok, user_1} =
  Accounts.register_user(
    %{
      email: "test@test.com",
      password: "testtesttest"
    },
    %{
      username: "Test",
      people_in_household: 1,
      newsletter: false
    }
  )

{:ok, user_2} =
  Accounts.register_user(
    %{
      email: "test2@test.com",
      password: "testtesttest"
    },
    %{
      username: "Test2",
      people_in_household: 1,
      newsletter: false
    }
  )

##
## Generate a valid API key
##

Repo.insert!(
  %ApiKey{
    name: "test",
    key: "dhHbRZx4sDE9QKecz+S/f8co4rIHbM4mqs3pM5kERKM="
  },
  returning: [:uuid]
)

##
## Create categories
##

aspirateur_traineau =
  Repo.insert!(
    %Category{
      name: "Aspirateur traineau",
      average_lifetime_m: 9
    },
    returning: [:uuid]
  )

_bouilloire =
  Repo.insert!(
    %Category{
      name: "Bouilloire",
      average_lifetime_m: 9
    },
    returning: [:uuid]
  )

_cafetière =
  Repo.insert!(
    %Category{
      name: "Catefière"
    },
    returning: [:uuid]
  )

_centrale_vapeur =
  Repo.insert!(
    %Category{
      name: "Centrale vapeur",
      average_lifetime_m: 8
    },
    returning: [:uuid]
  )

_congélateur =
  Repo.insert!(
    %Category{
      name: "Congélateur",
      average_lifetime_m: 12
    },
    returning: [:uuid]
  )

_fer_à_repasser =
  Repo.insert!(
    %Category{
      name: "Fer à repasser",
      average_lifetime_m: 8
    },
    returning: [:uuid]
  )

four_encastrable =
  Repo.insert!(
    %Category{
      name: "Four (encastrable)",
      average_lifetime_m: 11
    },
    returning: [:uuid]
  )

four_non_encastrable =
  Repo.insert!(
    %Category{
      name: "Four (non-encastrable)",
      average_lifetime_m: 11
    },
    returning: [:uuid]
  )

_grille_pain =
  Repo.insert!(
    %Category{
      name: "Grille-pain",
      average_lifetime_m: 12
    },
    returning: [:uuid]
  )

_hotte_visière =
  Repo.insert!(
    %Category{
      name: "Hotte visière",
      average_lifetime_m: 12
    },
    returning: [:uuid]
  )

lave_linge_hublot =
  Repo.insert!(
    %Category{
      name: "Lave-linge hublot",
      description: "Lave-linges qui ont un hublot.",
      average_lifetime_m: 10
    },
    returning: [:uuid]
  )

lave_linge_top =
  Repo.insert!(
    %Category{
      name: "Lave-linge top",
      description: "Lave-linges qui s’ouvrent par le dessus.",
      average_lifetime_m: 10
    },
    returning: [:uuid]
  )

_lave_vaisselle =
  Repo.insert!(
    %Category{
      name: "Lave-vaisselle",
      average_lifetime_m: 11
    },
    returning: [:uuid]
  )

machine_à_café =
  Repo.insert!(
    %Category{
      name: "Machine à café",
      average_lifetime_m: 7
    },
    returning: [:uuid]
  )

_machine_à_coudre =
  Repo.insert!(
    %Category{
      name: "Machine à coudre",
      average_lifetime_m: 20
    },
    returning: [:uuid]
  )

_micro_ondes =
  Repo.insert!(
    %Category{
      name: "Micro-ondes",
      average_lifetime_m: 11
    },
    returning: [:uuid]
  )

plaques_électriques =
  Repo.insert!(
    %Category{
      name: "Plaques de cuisson électriques"
    },
    returning: [:uuid]
  )

_plaques_gaz =
  Repo.insert!(
    %Category{
      name: "Plaques de cuisson au gaz"
    },
    returning: [:uuid]
  )

réfrigérateur =
  Repo.insert!(
    %Category{
      name: "Réfrigérateur",
      average_lifetime_m: 12
    },
    returning: [:uuid]
  )

sèche_linge_hublot =
  Repo.insert!(
    %Category{
      name: "Sèche-linge hublot",
      description: "Sèche-linges qui ont un hublot.",
      average_lifetime_m: 10
    },
    returning: [:uuid]
  )

sèche_linge_top =
  Repo.insert!(
    %Category{
      name: "Sèche-linge top",
      description: "Sèche-linges qui s’ouvrent par le dessus",
      average_lifetime_m: 10
    },
    returning: [:uuid]
  )

##
## Create manufacturers
##

inconnu =
  Repo.insert!(
    %Manufacturer{
      name: "Inconnu",
      description:
        "À utiliser pour les pièces détachées, lorsque le fabricant est
    inconnu, ce qui est souvent le cas."
    },
    returning: [:uuid]
  )

cooke_and_lewis =
  Repo.insert!(
    %Manufacturer{
      name: "Cooke & Lewis",
      description: "Marque appartenant au groupe Kingfisher (Brico Depot,
    Castorama…)."
    },
    returning: [:uuid]
  )

_delonghi =
  Repo.insert!(
    %Manufacturer{
      name: "Delonghi",
      description: "Le groupe De'Longhi S.p.a. est une entreprise italienne
    produisant des appareils électroménagers et notamment connue pour ses
    machines à café et climatiseurs."
    },
    returning: [:uuid]
  )

electrolux =
  Repo.insert!(
    %Manufacturer{
      name: "Electrolux",
      description: """
      Entreprise suédoise d’électroménager.
      """
    },
    returning: [:uuid]
  )

fagor =
  Repo.insert!(
    %Manufacturer{
      name: "Fagor",
      description: "Entreprise espagnole de fabrication de biens d'équipements
    domiciliée à Arrasate au Pays basque."
    },
    returning: [:uuid]
  )

lg =
  Repo.insert!(
    %Manufacturer{
      name: "LG",
      description: "Conglomérat industriel sud-coréen."
    },
    returning: [:uuid]
  )

_moulinex =
  Repo.insert!(
    %Manufacturer{
      name: "Moulinex",
      description: "Marque française de petit électroménager appartenant
    actuellement au groupe SEB."
    },
    returning: [:uuid]
  )

_panasonic =
  Repo.insert!(
    %Manufacturer{
      name: "Panasonic",
      description:
        "Groupe japonais spécialisé dans l’électronique grand public et
    professionnel."
    },
    returning: [:uuid]
  )

_philips =
  Repo.insert!(
    %Manufacturer{
      name: "Philips",
      description: "Société néerlandaise d'électronique, basée à Amsterdam."
    },
    returning: [:uuid]
  )

_samsung =
  Repo.insert!(
    %Manufacturer{
      name: "Samsung",
      description: "Fabricant coréen"
    },
    returning: [:uuid]
  )

_valberg =
  Repo.insert!(
    %Manufacturer{
      name: "Valberg",
      description: "Marque distributeur d’Electrodépot pour équiper la cuisine."
    },
    returning: [:uuid]
  )

whirlpool =
  Repo.insert!(
    %Manufacturer{
      name: "Whirlpool",
      description: "Entreprise américaine spécialisée dans la conception, la
    fabrication et la distribution d'appareils électroménagers"
    },
    returning: [:uuid]
  )

##
## Create products
##

four_encastrable_pyrolyse =
  Repo.insert!(
    %Product{
      category_uuid: four_encastrable.uuid,
      manufacturer_uuid: fagor.uuid,
      name: "Four encastrable pyrolyse",
      reference: "5H-741N3"
    },
    returning: [:uuid]
  )

lave_linge_lg =
  Repo.insert!(
    %Product{
      category_uuid: lave_linge_hublot.uuid,
      manufacturer_uuid: lg.uuid,
      name: "Lave-linge 8 KG | 6 Motion Direct Drive",
      reference: "F84J60WH"
    },
    returning: [:uuid]
  )

réfrigérateur_combiné =
  Repo.insert!(
    %Product{
      category_uuid: réfrigérateur.uuid,
      manufacturer_uuid: lg.uuid,
      name: "Réfrigirateur combiné",
      reference: "GBB61DSJZN"
    },
    returning: [:uuid]
  )

ultraperformer =
  Repo.insert!(
    %Product{
      category_uuid: aspirateur_traineau.uuid,
      manufacturer_uuid: electrolux.uuid,
      name: "UltraPerformer",
      reference: "ZUP3820B"
    },
    returning: [:uuid]
  )

plaques_de_cuisson =
  Repo.insert!(
    %Product{
      category_uuid: plaques_électriques.uuid,
      manufacturer_uuid: cooke_and_lewis.uuid,
      name: "Plaques de cuisson",
      reference: "CLCER30a",
      country_of_origin: "Chine"
    },
    returning: [:uuid]
  )

lave_linge_eletrolux =
  Repo.insert!(
    %Product{
      category_uuid: lave_linge_hublot.uuid,
      manufacturer_uuid: electrolux.uuid,
      name: "Lave-linge",
      reference: "EW2F7814FA – FLP544041",
      country_of_origin: "EU"
    },
    returning: [:uuid]
  )

réfrigérateur_whirlpool =
  Repo.insert!(
    %Product{
      category_uuid: réfrigérateur.uuid,
      manufacturer_uuid: whirlpool.uuid,
      name: "Réfrigérateur encastrable",
      reference: "W11257981"
    },
    returning: [:uuid]
  )

##
## Create parts
##

Repo.insert!(
  %Part{
    manufacturer_uuid: inconnu.uuid,
    products: [lave_linge_eletrolux, lave_linge_lg],
    name: "Tuyau d'eau alimentation droit/coudé 1,5m f/f",
    reference: "484000001132",
    main_material: "Plastique"
  },
  returning: [:uuid]
)

Repo.insert!(
  %Part{
    manufacturer_uuid: inconnu.uuid,
    products: [lave_linge_eletrolux],
    name: "Pressostat alternatif pour electrolux",
    reference: "3792216040",
    main_material: "Plastique"
  },
  returning: [:uuid]
)

Repo.insert!(
  %Part{
    manufacturer_uuid: inconnu.uuid,
    products: [lave_linge_eletrolux],
    name: "Courroie d'entraînement pour lave-linge",
    reference: "1323531200",
    main_material: "Plastique"
  },
  returning: [:uuid]
)

Repo.insert!(
  %Part{
    manufacturer_uuid: inconnu.uuid,
    products: [four_encastrable_pyrolyse],
    name: "Ampoule e14 28w",
    reference: "484000008834",
    main_material: "Métal"
  },
  returning: [:uuid]
)

Repo.insert!(
  %Part{
    manufacturer_uuid: inconnu.uuid,
    products: [four_encastrable_pyrolyse],
    name: "Moteur de ventilateur (sans hélice)",
    reference: "74x1146",
    main_material: "Métal"
  },
  returning: [:uuid]
)

Repo.insert!(
  %Part{
    manufacturer_uuid: inconnu.uuid,
    products: [four_encastrable_pyrolyse],
    name: "Hélice de ventilation de chaleur tournante",
    reference: "74x6900",
    main_material: "Métal"
  },
  returning: [:uuid]
)

Repo.insert!(
  %Part{
    manufacturer_uuid: inconnu.uuid,
    products: [four_encastrable_pyrolyse],
    name: "Résistance de voute de grille (2100w l360x320mm)",
    reference: "74x2310",
    main_material: "Métal"
  },
  returning: [:uuid]
)

##
## Create ownerships
##

Repo.insert!(
  %Ownership{
    product_uuid: four_encastrable_pyrolyse.uuid,
    profile_uuid: user_1.profile.uuid,
    date_of_purchase: ~D[2018-03-01],
    warranty_duration_m: 24,
    price_of_purchase: 429,
    public: false
  },
  returning: [:uuid]
)

Repo.insert!(
  %Ownership{
    product_uuid: lave_linge_lg.uuid,
    profile_uuid: user_1.profile.uuid,
    date_of_purchase: ~D[2020-01-15],
    warranty_duration_m: 60,
    price_of_purchase: 549,
    public: true
  },
  returning: [:uuid]
)

Repo.insert!(
  %Ownership{
    product_uuid: réfrigérateur_combiné.uuid,
    profile_uuid: user_2.profile.uuid,
    date_of_purchase: ~D[2021-02-14],
    warranty_duration_m: 120,
    price_of_purchase: 690,
    public: true
  },
  returning: [:uuid]
)

Repo.insert!(
  %Ownership{
    product_uuid: ultraperformer.uuid,
    profile_uuid: user_2.profile.uuid,
    date_of_purchase: ~D[2018-03-01],
    warranty_duration_m: 24,
    price_of_purchase: 190,
    public: true
  },
  returning: [:uuid]
)

Repo.insert!(
  %Ownership{
    product_uuid: plaques_de_cuisson.uuid,
    profile_uuid: user_2.profile.uuid,
    date_of_purchase: ~D[2023-01-01],
    warranty_duration_m: 0,
    public: false
  },
  returning: [:uuid]
)

Repo.insert!(
  %Ownership{
    product_uuid: lave_linge_eletrolux.uuid,
    profile_uuid: user_2.profile.uuid,
    date_of_purchase: ~D[2023-12-12],
    warranty_duration_m: 120,
    price_of_purchase: 499,
    public: true
  },
  returning: [:uuid]
)

Repo.insert!(
  %Ownership{
    product_uuid: réfrigérateur_whirlpool.uuid,
    profile_uuid: user_2.profile.uuid,
    date_of_purchase: ~D[2023-07-01],
    warranty_duration_m: 60,
    price_of_purchase: 550,
    public: false
  },
  returning: [:uuid]
)

##
## Create notification_templates
##

Repo.insert!(
  %NotificationTemplate{
    name: "Détartrage lave-linge",
    title: "Détartrage de votre lave-linge",
    content: "Versez 1 verre de vinaigre blanc (aussi appelé vanaigre ménager)
  directement dans le tambour de votre lave-linge, et lancez une machine à vide
  à 60°C.",
    condition: "Posséder un lave-linge.",
    need_action: false,
    categories: [lave_linge_hublot, lave_linge_top]
  },
  returning: [:uuid]
)

Repo.insert!(
  %NotificationTemplate{
    name: "Nettoyage filtre lave-linge",
    title: "Nettoyage du filtre de votre lave-linge",
    content: "Dévissez l’entrée du filtre de votre lave-linge. Procédez au
  nettoyage du filtre.",
    condition: "Posséder un lave-linge.",
    need_action: false,
    categories: [lave_linge_hublot, lave_linge_top]
  },
  returning: [:uuid]
)

Repo.insert!(
  %NotificationTemplate{
    name: "Nettoyage filtre sèche-linge",
    title: "Nettoyage du filtre de votre sèche-linge",
    content: "Dépoussiérez le filtre de votre sèche-linge après chaque
  utilisation.",
    condition: "Posséder un sèche-linge.",
    need_action: false,
    categories: [sèche_linge_hublot, sèche_linge_top]
  },
  returning: [:uuid]
)

Repo.insert!(
  %NotificationTemplate{
    name: "Nettoyage joint machine à café",
    title: "Nettoyage du joint de votre machine à café",
    content: "Ouvrez votre machine à café. Retirez le joint de l’unité de
  brassage. Passez ce joint au lave-vaisselle. Réinstallez le joint.",
    condition: "Posséder une machine à café.",
    need_action: false,
    categories: [machine_à_café]
  },
  returning: [:uuid]
)

Repo.insert!(
  %NotificationTemplate{
    name: "Nettoyage four",
    title: "Nettoyage de votre four",
    content: "Regardez dans le manuel de votre four s’il dispose d’une fonction
  de nettoyage par pyrolyse. Si c’est le cas, effectuez un nettoyage.",
    condition: "Posséder un four.",
    need_action: false,
    categories: [four_encastrable, four_non_encastrable]
  },
  returning: [:uuid]
)
