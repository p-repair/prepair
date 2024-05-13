######################################
# Script for populating the database #
######################################

alias Prepair.Repo
alias Prepair.LegacyContexts.Accounts
alias Prepair.LegacyContexts.Auth.ApiKey
alias Prepair.LegacyContexts.Notifications.NotificationTemplate
alias Prepair.LegacyContexts.Products.Category
alias Prepair.LegacyContexts.Products.Manufacturer
alias Prepair.LegacyContexts.Products.Product
alias Prepair.LegacyContexts.Products.Part
alias Prepair.LegacyContexts.Profiles.Ownership

##
## Create users
##

{:ok, user_1} =
  Accounts.register_user(%{
    username: "Test",
    email: "test@test.com",
    password: "Yolo777!",
    password_confirmation: "Yolo777!",
    people_in_household: 1,
    newsletter: false
  })

{:ok, user_2} =
  Accounts.register_user(%{
    username: "Test2",
    email: "test2@test.com",
    password: "Yolo777!",
    password_confirmation: "Yolo777!",
    people_in_household: 1,
    newsletter: false
  })

##
## Update user_1 to admin
##

Accounts.update_user_role(user_1, :admin)

##
## Generate a valid API key
##

Repo.insert!(
  %ApiKey{
    name: "test",
    key: "dhHbRZx4sDE9QKecz+S/f8co4rIHbM4mqs3pM5kERKM="
  },
  returning: [:id]
)

##
## Create categories
##

aspirateur_traineau =
  Repo.insert!(
    %Category{
      name: "Aspirateur traineau",
      average_lifetime_m: 108
    },
    returning: [:id]
  )

_bouilloire =
  Repo.insert!(
    %Category{
      name: "Bouilloire",
      average_lifetime_m: 108
    },
    returning: [:id]
  )

_cafetière =
  Repo.insert!(
    %Category{
      name: "Catefière"
    },
    returning: [:id]
  )

_centrale_vapeur =
  Repo.insert!(
    %Category{
      name: "Centrale vapeur",
      average_lifetime_m: 96
    },
    returning: [:id]
  )

_congélateur =
  Repo.insert!(
    %Category{
      name: "Congélateur",
      average_lifetime_m: 144
    },
    returning: [:id]
  )

_fer_à_repasser =
  Repo.insert!(
    %Category{
      name: "Fer à repasser",
      average_lifetime_m: 96
    },
    returning: [:id]
  )

four_encastrable =
  Repo.insert!(
    %Category{
      name: "Four (encastrable)",
      average_lifetime_m: 132
    },
    returning: [:id]
  )

four_non_encastrable =
  Repo.insert!(
    %Category{
      name: "Four (non-encastrable)",
      average_lifetime_m: 132
    },
    returning: [:id]
  )

_grille_pain =
  Repo.insert!(
    %Category{
      name: "Grille-pain",
      average_lifetime_m: 144
    },
    returning: [:id]
  )

_hotte_visière =
  Repo.insert!(
    %Category{
      name: "Hotte visière",
      average_lifetime_m: 144
    },
    returning: [:id]
  )

lave_linge_hublot =
  Repo.insert!(
    %Category{
      name: "Lave-linge hublot",
      description: "Lave-linges qui ont un hublot.",
      average_lifetime_m: 120
    },
    returning: [:id]
  )

lave_linge_top =
  Repo.insert!(
    %Category{
      name: "Lave-linge top",
      description: "Lave-linges qui s’ouvrent par le dessus.",
      average_lifetime_m: 120
    },
    returning: [:id]
  )

_lave_vaisselle =
  Repo.insert!(
    %Category{
      name: "Lave-vaisselle",
      average_lifetime_m: 132
    },
    returning: [:id]
  )

machine_à_café =
  Repo.insert!(
    %Category{
      name: "Machine à café",
      average_lifetime_m: 84
    },
    returning: [:id]
  )

_machine_à_coudre =
  Repo.insert!(
    %Category{
      name: "Machine à coudre",
      average_lifetime_m: 240
    },
    returning: [:id]
  )

_micro_ondes =
  Repo.insert!(
    %Category{
      name: "Micro-ondes",
      average_lifetime_m: 132
    },
    returning: [:id]
  )

plaques_électriques =
  Repo.insert!(
    %Category{
      name: "Plaques de cuisson électriques"
    },
    returning: [:id]
  )

_plaques_gaz =
  Repo.insert!(
    %Category{
      name: "Plaques de cuisson au gaz"
    },
    returning: [:id]
  )

réfrigérateur =
  Repo.insert!(
    %Category{
      name: "Réfrigérateur",
      average_lifetime_m: 144
    },
    returning: [:id]
  )

sèche_linge_hublot =
  Repo.insert!(
    %Category{
      name: "Sèche-linge hublot",
      description: "Sèche-linges qui ont un hublot.",
      average_lifetime_m: 120
    },
    returning: [:id]
  )

sèche_linge_top =
  Repo.insert!(
    %Category{
      name: "Sèche-linge top",
      description: "Sèche-linges qui s’ouvrent par le dessus",
      average_lifetime_m: 120
    },
    returning: [:id]
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
    returning: [:id]
  )

cooke_and_lewis =
  Repo.insert!(
    %Manufacturer{
      name: "Cooke & Lewis",
      description: "Marque appartenant au groupe Kingfisher (Brico Depot,
    Castorama…)."
    },
    returning: [:id]
  )

_delonghi =
  Repo.insert!(
    %Manufacturer{
      name: "Delonghi",
      description: "Le groupe De'Longhi S.p.a. est une entreprise italienne
    produisant des appareils électroménagers et notamment connue pour ses
    machines à café et climatiseurs."
    },
    returning: [:id]
  )

electrolux =
  Repo.insert!(
    %Manufacturer{
      name: "Electrolux",
      description: """
      Entreprise suédoise d’électroménager.
      """
    },
    returning: [:id]
  )

fagor =
  Repo.insert!(
    %Manufacturer{
      name: "Fagor",
      description: "Entreprise espagnole de fabrication de biens d'équipements
    domiciliée à Arrasate au Pays basque."
    },
    returning: [:id]
  )

lg =
  Repo.insert!(
    %Manufacturer{
      name: "LG",
      description: "Conglomérat industriel sud-coréen."
    },
    returning: [:id]
  )

_moulinex =
  Repo.insert!(
    %Manufacturer{
      name: "Moulinex",
      description: "Marque française de petit électroménager appartenant
    actuellement au groupe SEB."
    },
    returning: [:id]
  )

_panasonic =
  Repo.insert!(
    %Manufacturer{
      name: "Panasonic",
      description:
        "Groupe japonais spécialisé dans l’électronique grand public et
    professionnel."
    },
    returning: [:id]
  )

_philips =
  Repo.insert!(
    %Manufacturer{
      name: "Philips",
      description: "Société néerlandaise d'électronique, basée à Amsterdam."
    },
    returning: [:id]
  )

_samsung =
  Repo.insert!(
    %Manufacturer{
      name: "Samsung",
      description: "Fabricant coréen"
    },
    returning: [:id]
  )

_valberg =
  Repo.insert!(
    %Manufacturer{
      name: "Valberg",
      description: "Marque distributeur d’Electrodépot pour équiper la cuisine."
    },
    returning: [:id]
  )

whirlpool =
  Repo.insert!(
    %Manufacturer{
      name: "Whirlpool",
      description: "Entreprise américaine spécialisée dans la conception, la
    fabrication et la distribution d'appareils électroménagers"
    },
    returning: [:id]
  )

##
## Create products
##

four_encastrable_pyrolyse =
  Repo.insert!(
    %Product{
      category_id: four_encastrable.id,
      manufacturer_id: fagor.id,
      name: "Four encastrable pyrolyse",
      reference: "5H-741N3"
    },
    returning: [:id]
  )

lave_linge_lg =
  Repo.insert!(
    %Product{
      category_id: lave_linge_hublot.id,
      manufacturer_id: lg.id,
      name: "Lave-linge 8 KG | 6 Motion Direct Drive",
      reference: "F84J60WH"
    },
    returning: [:id]
  )

réfrigérateur_combiné =
  Repo.insert!(
    %Product{
      category_id: réfrigérateur.id,
      manufacturer_id: lg.id,
      name: "Réfrigirateur combiné",
      reference: "GBB61DSJZN"
    },
    returning: [:id]
  )

ultraperformer =
  Repo.insert!(
    %Product{
      category_id: aspirateur_traineau.id,
      manufacturer_id: electrolux.id,
      name: "UltraPerformer",
      reference: "ZUP3820B"
    },
    returning: [:id]
  )

plaques_de_cuisson =
  Repo.insert!(
    %Product{
      category_id: plaques_électriques.id,
      manufacturer_id: cooke_and_lewis.id,
      name: "Plaques de cuisson",
      reference: "CLCER30a",
      country_of_origin: "Chine"
    },
    returning: [:id]
  )

lave_linge_eletrolux =
  Repo.insert!(
    %Product{
      category_id: lave_linge_hublot.id,
      manufacturer_id: electrolux.id,
      name: "Lave-linge",
      reference: "EW2F7814FA – FLP544041",
      country_of_origin: "EU"
    },
    returning: [:id]
  )

réfrigérateur_whirlpool =
  Repo.insert!(
    %Product{
      category_id: réfrigérateur.id,
      manufacturer_id: whirlpool.id,
      name: "Réfrigérateur encastrable",
      reference: "W11257981"
    },
    returning: [:id]
  )

##
## Create parts
##

Repo.insert!(
  %Part{
    manufacturer_id: inconnu.id,
    products: [lave_linge_eletrolux, lave_linge_lg],
    name: "Tuyau d'eau alimentation droit/coudé 1,5m f/f",
    reference: "484000001132",
    main_material: "Plastique"
  },
  returning: [:id]
)

Repo.insert!(
  %Part{
    manufacturer_id: inconnu.id,
    products: [lave_linge_eletrolux],
    name: "Pressostat alternatif pour electrolux",
    reference: "3792216040",
    main_material: "Plastique"
  },
  returning: [:id]
)

Repo.insert!(
  %Part{
    manufacturer_id: inconnu.id,
    products: [lave_linge_eletrolux],
    name: "Courroie d'entraînement pour lave-linge",
    reference: "1323531200",
    main_material: "Plastique"
  },
  returning: [:id]
)

Repo.insert!(
  %Part{
    manufacturer_id: inconnu.id,
    products: [four_encastrable_pyrolyse],
    name: "Ampoule e14 28w",
    reference: "484000008834",
    main_material: "Métal"
  },
  returning: [:id]
)

Repo.insert!(
  %Part{
    manufacturer_id: inconnu.id,
    products: [four_encastrable_pyrolyse],
    name: "Moteur de ventilateur (sans hélice)",
    reference: "74x1146",
    main_material: "Métal"
  },
  returning: [:id]
)

Repo.insert!(
  %Part{
    manufacturer_id: inconnu.id,
    products: [four_encastrable_pyrolyse],
    name: "Hélice de ventilation de chaleur tournante",
    reference: "74x6900",
    main_material: "Métal"
  },
  returning: [:id]
)

Repo.insert!(
  %Part{
    manufacturer_id: inconnu.id,
    products: [four_encastrable_pyrolyse],
    name: "Résistance de voute de grille (2100w l360x320mm)",
    reference: "74x2310",
    main_material: "Métal"
  },
  returning: [:id]
)

##
## Create ownerships
##

Repo.insert!(
  %Ownership{
    product_id: four_encastrable_pyrolyse.id,
    profile_id: user_1.profile.id,
    date_of_purchase: ~D[2018-03-01],
    warranty_duration_m: 24,
    price_of_purchase: 429,
    public: false
  },
  returning: [:id]
)

Repo.insert!(
  %Ownership{
    product_id: lave_linge_lg.id,
    profile_id: user_1.profile.id,
    date_of_purchase: ~D[2020-01-15],
    warranty_duration_m: 60,
    price_of_purchase: 549,
    public: true
  },
  returning: [:id]
)

Repo.insert!(
  %Ownership{
    product_id: réfrigérateur_combiné.id,
    profile_id: user_2.profile.id,
    date_of_purchase: ~D[2021-02-14],
    warranty_duration_m: 120,
    price_of_purchase: 690,
    public: true
  },
  returning: [:id]
)

Repo.insert!(
  %Ownership{
    product_id: ultraperformer.id,
    profile_id: user_2.profile.id,
    date_of_purchase: ~D[2018-03-01],
    warranty_duration_m: 24,
    price_of_purchase: 190,
    public: true
  },
  returning: [:id]
)

Repo.insert!(
  %Ownership{
    product_id: plaques_de_cuisson.id,
    profile_id: user_2.profile.id,
    date_of_purchase: ~D[2023-01-01],
    warranty_duration_m: 0,
    public: false
  },
  returning: [:id]
)

Repo.insert!(
  %Ownership{
    product_id: lave_linge_eletrolux.id,
    profile_id: user_2.profile.id,
    date_of_purchase: ~D[2023-12-12],
    warranty_duration_m: 120,
    price_of_purchase: 499,
    public: true
  },
  returning: [:id]
)

Repo.insert!(
  %Ownership{
    product_id: réfrigérateur_whirlpool.id,
    profile_id: user_2.profile.id,
    date_of_purchase: ~D[2023-07-01],
    warranty_duration_m: 60,
    price_of_purchase: 550,
    public: false
  },
  returning: [:id]
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
  returning: [:id]
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
  returning: [:id]
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
  returning: [:id]
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
  returning: [:id]
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
  returning: [:id]
)
