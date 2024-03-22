######################################
# Script for populating the database #
######################################

alias Prepair.Repo
alias Prepair.Accounts
alias Prepair.Auth.ApiKey
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

Repo.insert!(%ApiKey{
  name: "test",
  key: "dhHbRZx4sDE9QKecz+S/f8co4rIHbM4mqs3pM5kERKM="
})

##
## Create categories
##

aspirateur_traineau =
  Repo.insert!(%Category{
    name: "Aspirateur traineau",
    average_lifetime_m: 9
  })

_bouilloire =
  Repo.insert!(%Category{
    name: "Bouilloire",
    average_lifetime_m: 9
  })

_cafetière =
  Repo.insert!(%Category{
    name: "Catefière"
  })

_centrale_vapeur =
  Repo.insert!(%Category{
    name: "Centrale vapeur",
    average_lifetime_m: 8
  })

_congélateur =
  Repo.insert!(%Category{
    name: "Congélateur",
    average_lifetime_m: 12
  })

_fer_à_repasser =
  Repo.insert!(%Category{
    name: "Fer à repasser",
    average_lifetime_m: 8
  })

four_encastrable =
  Repo.insert!(%Category{
    name: "Four (encastrable)",
    average_lifetime_m: 11
  })

_four_non_encastrable =
  Repo.insert!(%Category{
    name: "Four (non-encastrable)",
    average_lifetime_m: 11
  })

_grille_pain =
  Repo.insert!(%Category{
    name: "Grille-pain",
    average_lifetime_m: 12
  })

_hotte_visière =
  Repo.insert!(%Category{
    name: "Hotte visière",
    average_lifetime_m: 12
  })

lave_linge_hublot =
  Repo.insert!(%Category{
    name: "Lave-linge hublot",
    description: "Lave-linges qui ont un hublot.",
    average_lifetime_m: 10
  })

_lave_linge_top =
  Repo.insert!(%Category{
    name: "Lave-linge top",
    description: "Lave-linges qui s’ouvrent par le dessus.",
    average_lifetime_m: 10
  })

_lave_vaisselle =
  Repo.insert!(%Category{
    name: "Lave-vaisselle",
    average_lifetime_m: 11
  })

_machine_à_café =
  Repo.insert!(%Category{
    name: "Machine à café",
    average_lifetime_m: 7
  })

_machine_à_coudre =
  Repo.insert!(%Category{
    name: "Machine à coudre",
    average_lifetime_m: 20
  })

_micro_ondes =
  Repo.insert!(%Category{
    name: "Micro-ondes",
    average_lifetime_m: 11
  })

plaques_électriques =
  Repo.insert!(%Category{
    name: "Plaques de cuisson électriques"
  })

_plaques_gaz =
  Repo.insert!(%Category{
    name: "Plaques de cuisson au gaz"
  })

réfrigérateur =
  Repo.insert!(%Category{
    name: "Réfrigérateur",
    average_lifetime_m: 12
  })

_sèche_linge_hublot =
  Repo.insert!(%Category{
    name: "Sèche-linge hublot",
    description: "Sèche-linges qui ont un hublot.",
    average_lifetime_m: 10
  })

_sèche_linge_top =
  Repo.insert!(%Category{
    name: "Sèche-linge top",
    description: "Sèche-linges qui s’ouvrent par le dessus",
    average_lifetime_m: 10
  })

##
## Create manufacturers
##

inconnu =
  Repo.insert!(%Manufacturer{
    name: "Inconnu",
    description: "À utiliser pour les pièces détachées, lorsque le fabricant est
    inconnu, ce qui est souvent le cas."
  })

cooke_and_lewis =
  Repo.insert!(%Manufacturer{
    name: "Cooke & Lewis",
    description: "Marque appartenant au groupe Kingfisher (Brico Depot,
    Castorama…)."
  })

_delonghi =
  Repo.insert!(%Manufacturer{
    name: "Delonghi",
    description: "Le groupe De'Longhi S.p.a. est une entreprise italienne
    produisant des appareils électroménagers et notamment connue pour ses
    machines à café et climatiseurs."
  })

electrolux =
  Repo.insert!(%Manufacturer{
    name: "Electrolux",
    description: """
    Entreprise suédoise d’électroménager.
    """
  })

fagor =
  Repo.insert!(%Manufacturer{
    name: "Fagor",
    description: "Entreprise espagnole de fabrication de biens d'équipements
    domiciliée à Arrasate au Pays basque."
  })

lg =
  Repo.insert!(%Manufacturer{
    name: "LG",
    description: "Conglomérat industriel sud-coréen."
  })

_moulinex =
  Repo.insert!(%Manufacturer{
    name: "Moulinex",
    description: "Marque française de petit électroménager appartenant
    actuellement au groupe SEB."
  })

_panasonic =
  Repo.insert!(%Manufacturer{
    name: "Panasonic",
    description: "Groupe japonais spécialisé dans l’électronique grand public et
    professionnel."
  })

_philips =
  Repo.insert!(%Manufacturer{
    name: "Philips",
    description: "Société néerlandaise d'électronique, basée à Amsterdam."
  })

_samsung =
  Repo.insert!(%Manufacturer{
    name: "Samsung",
    description: "Fabricant coréen"
  })

_valberg =
  Repo.insert!(%Manufacturer{
    name: "Valberg",
    description: "Marque distributeur d’Electrodépot pour équiper la cuisine."
  })

whirlpool =
  Repo.insert!(%Manufacturer{
    name: "Whirlpool",
    description: "Entreprise américaine spécialisée dans la conception, la
    fabrication et la distribution d'appareils électroménagers"
  })

##
## Create products
##

four_encastrable_pyrolyse =
  Repo.insert!(%Product{
    category_id: four_encastrable.id,
    manufacturer_id: fagor.id,
    name: "Four encastrable pyrolyse",
    reference: "5H-741N3"
  })

lave_linge_lg =
  Repo.insert!(%Product{
    category_id: lave_linge_hublot.id,
    manufacturer_id: lg.id,
    name: "Lave-linge 8 KG | 6 Motion Direct Drive",
    reference: "F84J60WH"
  })

réfrigérateur_combiné =
  Repo.insert!(%Product{
    category_id: réfrigérateur.id,
    manufacturer_id: lg.id,
    name: "Réfrigirateur combiné",
    reference: "GBB61DSJZN"
  })

ultraperformer =
  Repo.insert!(%Product{
    category_id: aspirateur_traineau.id,
    manufacturer_id: electrolux.id,
    name: "UltraPerformer",
    reference: "ZUP3820B"
  })

plaques_de_cuisson =
  Repo.insert!(%Product{
    category_id: plaques_électriques.id,
    manufacturer_id: cooke_and_lewis.id,
    name: "Plaques de cuisson",
    reference: "CLCER30a",
    country_of_origin: "Chine"
  })

lave_linge_eletrolux =
  Repo.insert!(%Product{
    category_id: lave_linge_hublot.id,
    manufacturer_id: electrolux.id,
    name: "Lave-linge",
    reference: "EW2F7814FA – FLP544041",
    country_of_origin: "EU"
  })

réfrigérateur_whirlpool =
  Repo.insert!(%Product{
    category_id: réfrigérateur.id,
    manufacturer_id: whirlpool.id,
    name: "Réfrigérateur encastrable",
    reference: "W11257981"
  })

##
## Create parts
##

Repo.insert!(%Part{
  manufacturer_id: inconnu.id,
  products: [lave_linge_eletrolux, lave_linge_lg],
  name: "Tuyau d'eau alimentation droit/coudé 1,5m f/f",
  reference: "484000001132",
  main_material: "Plastique"
})

Repo.insert!(%Part{
  manufacturer_id: inconnu.id,
  products: [lave_linge_eletrolux],
  name: "Pressostat alternatif pour electrolux",
  reference: "3792216040",
  main_material: "Plastique"
})

Repo.insert!(%Part{
  manufacturer_id: inconnu.id,
  products: [lave_linge_eletrolux],
  name: "Courroie d'entraînement pour lave-linge",
  reference: "1323531200",
  main_material: "Plastique"
})

Repo.insert!(%Part{
  manufacturer_id: inconnu.id,
  products: [four_encastrable_pyrolyse],
  name: "Ampoule e14 28w",
  reference: "484000008834",
  main_material: "Métal"
})

Repo.insert!(%Part{
  manufacturer_id: inconnu.id,
  products: [four_encastrable_pyrolyse],
  name: "Moteur de ventilateur (sans hélice)",
  reference: "74x1146",
  main_material: "Métal"
})

Repo.insert!(%Part{
  manufacturer_id: inconnu.id,
  products: [four_encastrable_pyrolyse],
  name: "Hélice de ventilation de chaleur tournante",
  reference: "74x6900",
  main_material: "Métal"
})

Repo.insert!(%Part{
  manufacturer_id: inconnu.id,
  products: [four_encastrable_pyrolyse],
  name: "Résistance de voute de grille (2100w l360x320mm)",
  reference: "74x2310",
  main_material: "Métal"
})

##
## Create ownerships
##

Repo.insert!(%Ownership{
  product_id: four_encastrable_pyrolyse.id,
  profile_id: user_1.profile.id,
  date_of_purchase: ~D[2018-03-01],
  warranty_duration_m: 24,
  price_of_purchase: 429,
  public: false
})

Repo.insert!(%Ownership{
  product_id: lave_linge_lg.id,
  profile_id: user_1.profile.id,
  date_of_purchase: ~D[2020-01-15],
  warranty_duration_m: 60,
  price_of_purchase: 549,
  public: true
})

Repo.insert!(%Ownership{
  product_id: réfrigérateur_combiné.id,
  profile_id: user_2.profile.id,
  date_of_purchase: ~D[2021-02-14],
  warranty_duration_m: 120,
  price_of_purchase: 690,
  public: true
})

Repo.insert!(%Ownership{
  product_id: ultraperformer.id,
  profile_id: user_2.profile.id,
  date_of_purchase: ~D[2018-03-01],
  warranty_duration_m: 24,
  price_of_purchase: 190,
  public: true
})

Repo.insert!(%Ownership{
  product_id: plaques_de_cuisson.id,
  profile_id: user_2.profile.id,
  date_of_purchase: ~D[2023-01-01],
  warranty_duration_m: 0,
  public: false
})

Repo.insert!(%Ownership{
  product_id: lave_linge_eletrolux.id,
  profile_id: user_2.profile.id,
  date_of_purchase: ~D[2023-12-12],
  warranty_duration_m: 120,
  price_of_purchase: 499,
  public: true
})

Repo.insert!(%Ownership{
  product_id: réfrigérateur_whirlpool.id,
  profile_id: user_2.profile.id,
  date_of_purchase: ~D[2023-07-01],
  warranty_duration_m: 60,
  price_of_purchase: 550,
  public: false
})
