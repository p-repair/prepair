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

floorstanding_speaker =
  Repo.insert!(%Category{
    name: "Floorstanding Speaker",
    description: "Speakers that stands directly on the floor"
  })

bookshelf_speaker =
  Repo.insert!(%Category{
    name: "Bookshelf Speaker",
    description: "Speakers that must not stand directly on the floor"
  })

amplifier =
  Repo.insert!(%Category{
    name: "Amplifier",
    description: "Hi-Fi amplifiers."
  })

smartphone =
  Repo.insert!(%Category{
    name: "Smartphone",
    description: "Much more than just a phone."
  })

##
## Create manufacturers
##

samsung =
  Repo.insert!(%Manufacturer{
    name: "Samsung",
    description: """
    A Korean brand, mostly known for their electronic devices (smartphones, TVs,
    screens, etc…).
    """
  })

rega =
  Repo.insert!(%Manufacturer{
    name: "Rega",
    description: """
    An English brand, specialized in HiFi (amplificators, turntables, etc…).
    """
  })

focal =
  Repo.insert!(%Manufacturer{
    name: "Focal",
    description: "A French brand which manufactures HiFi speakers."
  })

##
## Create products
##

brio =
  Repo.insert!(%Product{
    category_id: amplifier.id,
    manufacturer_id: rega.id,
    name: "Brio",
    reference: "REGABRIO17NR",
    description: "An integrated amplifier",
    average_lifetime_m: 240,
    country_of_origin: "England",
    start_of_production: ~D[2017-06-12]
  })

elex_r =
  Repo.insert!(%Product{
    category_id: amplifier.id,
    manufacturer_id: rega.id,
    name: "Elex-R",
    reference: "REGAELEXRNR",
    description: "An integrated amplifier",
    average_lifetime_m: 240,
    country_of_origin: "England"
  })

galaxy_s9 =
  Repo.insert!(%Product{
    category_id: smartphone.id,
    manufacturer_id: samsung.id,
    name: "Galaxy S9",
    reference: "SM-G960F",
    description: "A smartphone",
    average_lifetime_m: 36,
    country_of_origin: "China",
    start_of_production: ~D[2018-03-01]
  })

chorus_706 =
  Repo.insert!(%Product{
    category_id: bookshelf_speaker.id,
    manufacturer_id: focal.id,
    name: "Chorus 706",
    reference: "JMLABFOCAL706VBA",
    average_lifetime_m: 240,
    description: "HiFi speakers",
    country_of_origin: "France"
  })

aria_906 =
  Repo.insert!(%Product{
    category_id: floorstanding_speaker.id,
    manufacturer_id: focal.id,
    name: "Aria 906",
    reference: "EAR9090601-NO001",
    average_lifetime_m: 240,
    description: "HiFi speakers",
    country_of_origin: "France"
  })

##
## Create parts
##

Repo.insert!(%Part{
  manufacturer_id: samsung.id,
  product_ids: [galaxy_s9.id],
  name: "Microphone",
  reference: "MIC272-2017",
  average_lifetime_m: 60,
  country_of_origin: "China",
  main_material: "Metal"
})

Repo.insert!(%Part{
  manufacturer_id: rega.id,
  product_ids: [brio.id, elex_r.id],
  name: "Condensateur",
  reference: "COND-232312",
  average_lifetime_m: 240,
  country_of_origin: "England",
  main_material: "Metal"
})

Repo.insert!(%Part{
  manufacturer_id: focal.id,
  product_ids: [chorus_706.id, aria_906.id],
  name: "Membrane",
  reference: "231018MENB",
  average_lifetime_m: 240,
  country_of_origin: "France",
  main_material: "Wood"
})

##
## Create ownerships
##

Repo.insert!(%Ownership{
  product_id: brio.id,
  profile_id: user_1.profile.id,
  date_of_purchase: ~D[2020-12-11],
  warranty_duration_m: 24,
  price_of_purchase: 800,
  public: true
})

Repo.insert!(%Ownership{
  product_id: chorus_706.id,
  profile_id: user_1.profile.id,
  date_of_purchase: ~D[2015-04-30],
  warranty_duration_m: 24,
  price_of_purchase: 400,
  public: false
})

Repo.insert!(%Ownership{
  product_id: galaxy_s9.id,
  profile_id: user_2.profile.id,
  date_of_purchase: ~D[2021-11-27],
  warranty_duration_m: 12,
  price_of_purchase: 200,
  public: false
})
