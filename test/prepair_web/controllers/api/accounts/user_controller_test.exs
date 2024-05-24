defmodule PrepairWeb.Api.Accounts.UserControllerTest do
  use PrepairWeb.ConnCase, async: true

  alias Prepair.LegacyContexts.Accounts
  alias Prepair.Repo

  import Ecto.Query
  import Prepair.LegacyContexts.AccountsFixtures
  import Prepair.LegacyContexts.ProfilesFixtures

  defp get_user_token_from_user_id(id) do
    query =
      Accounts.UserToken
      |> where([t], t.user_id == ^id)
      |> select([t], t.token)

    Repo.all(query)
    |> List.first()
    |> Base.encode64()
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  setup [:create_and_set_api_key]

  ##############################################################################
  ########################## VISITORS - AUTHORIZATION ##########################
  ##############################################################################
  describe "visitors authorization:" do
    ######################## WHAT VISITORS CAN DO ? ############################

    @tag :user_controller
    test "visitors can register for an account", %{conn: conn} do
      password = valid_user_password()
      email = unique_user_email()
      profile = profile_valid_attrs()

      registration =
        %{
          username: profile.username,
          email: email,
          password: password,
          password_confirmation: password,
          people_in_household: profile.people_in_household,
          newsletter: profile.newsletter
        }

      assert conn
             |> post(~p"/api/v1/users/register", %{registration: registration})
             |> json_response(200)
    end

    # Visitors can log in the app (tested in SessionControllerTest).

    ####################### WHAT VISITORS CANNOT DO ? ##########################

    @tag :user_controller
    test "visitors cannot fetch the current user id", %{conn: conn} do
      assert conn
             |> get(~p"/api/v1/users")
             |> json_response(401)
    end

    @tag :user_controller
    test "visitors cannot update password", %{conn: conn} do
      assert conn
             |> put(~p"/api/v1/users/update_password", %{})
             |> json_response(401)
    end

    @tag :user_controller
    test "visitors cannot update email", %{conn: conn} do
      assert conn
             |> put(~p"/api/v1/users/update_email", %{})
             |> json_response(401)
    end
  end

  ##############################################################################
  ########################### USERS - AUTHORIZATION ############################
  ##############################################################################

  ########################### WHAT USERS CAN DO ? ############################

  # Fetch the current_user id (tested below).
  # Udpate their password (tested below).
  # Update their email (tested below).

  ######################### WHAT USERS CANNOT DO ? ###########################

  # TODO: User cannot register? API redirection? Or not needed?

  ##############################################################################
  ###################### FEATURES TESTS - USER | ADMIN #########################
  ##############################################################################

  describe "GET /api/v1/users" do
    setup [:register_and_log_in_user]

    @tag :user_controller
    test "fetch the current user id",
         %{conn: conn, user: user} do
      conn =
        get(conn, ~p"/api/v1/users")

      assert json_response(conn, 200) == %{"data" => %{"id" => user.id}}
    end
  end

  describe "POST /api/v1/users/register" do
    @tag :user_controller
    test "creates a new user when data is valid", %{conn: conn} do
      password = valid_user_password()
      email = unique_user_email()
      profile = profile_valid_attrs()

      registration =
        %{
          username: profile.username,
          email: email,
          password: password,
          password_confirmation: password,
          people_in_household: profile.people_in_household,
          newsletter: profile.newsletter
        }

      conn =
        post(conn, ~p"/api/v1/users/register", %{registration: registration})

      assert %{"user_id" => user_id} = json_response(conn, 200)["data"]

      user = Accounts.get_user!(user_id)
      token = get_user_token_from_user_id(user_id)

      assert json_response(conn, 200)["data"] == %{
               "token" => token,
               "user_id" => user.id
             }
    end

    @tag :user_controller
    test "raises an error when invalid email is given", %{conn: conn} do
      password = valid_user_password()
      profile = profile_valid_attrs()

      registration = %{
        username: profile.username,
        email: "invalid_email",
        password: password,
        password_confirmation: password,
        people_in_household: profile.people_in_household,
        newsletter: profile.newsletter
      }

      conn =
        post(conn, ~p"/api/v1/users/register", %{registration: registration})

      response = json_response(conn, 422)

      assert %{
               "errors" => %{"email" => ["must have the @ sign and no spaces"]}
             } ==
               response
    end

    @tag :user_controller
    test "raises an error when password and password confirmation don’t match",
         %{conn: conn} do
      password = valid_user_password()
      password_2 = valid_user_password()
      email = unique_user_email()
      profile = profile_valid_attrs()

      registration =
        user_valid_attrs(%{
          username: profile.username,
          email: email,
          password: password,
          password_confirmation: password_2,
          people_in_household: profile.people_in_household,
          newsletter: profile.newsletter
        })

      conn =
        post(conn, ~p"/api/v1/users/register", %{registration: registration})

      response = json_response(conn, 422)

      assert %{
               "errors" => %{
                 "password_confirmation" => [
                   "does not match"
                 ]
               }
             } ==
               response
    end

    @tag :user_controller
    test "raises an error when invalid password is given",
         %{conn: conn} do
      password = "short"
      email = unique_user_email()
      profile = profile_valid_attrs()

      registration =
        user_valid_attrs(%{
          username: profile.username,
          email: email,
          password: password,
          password_confirmation: password,
          people_in_household: profile.people_in_household,
          newsletter: profile.newsletter
        })

      conn =
        post(conn, ~p"/api/v1/users/register", %{registration: registration})

      response = json_response(conn, 422)

      assert %{
               "errors" => %{
                 "password" => [
                   "at least one digit or punctuation character",
                   "at least one upper case character",
                   "should be at least 8 character(s)"
                 ]
               }
             } ==
               response
    end

    @tag :user_controller
    test "raises an errors if username has already been taken",
         %{conn: conn} do
      email = unique_user_email()
      password = valid_user_password()
      profile = profile_fixture()

      registration = %{
        username: profile.username,
        email: email,
        password: password,
        password_confirmation: password,
        people_in_household: 1,
        newsletter: true
      }

      conn =
        post(conn, ~p"/api/v1/users/register", %{registration: registration})

      response = json_response(conn, 422)

      assert %{
               "errors" => %{
                 "username" => ["has already been taken"]
               }
             } ==
               response
    end

    @tag :user_controller
    test "raises an errors if email has already been taken",
         %{conn: conn} do
      user = user_fixture()
      password = valid_user_password()
      profile = profile_valid_attrs()

      registration = %{
        username: profile.username,
        email: user.email,
        password: password,
        password_confirmation: password,
        people_in_household: profile.people_in_household,
        newsletter: profile.newsletter
      }

      conn =
        post(conn, ~p"/api/v1/users/register", %{registration: registration})

      response = json_response(conn, 422)

      assert %{
               "errors" => %{
                 "email" => ["has already been taken"]
               }
             } ==
               response
    end

    @tag :user_controller
    test "raises all errors at once when all data is invalid",
         %{conn: conn} do
      user = user_fixture()
      profile = profile_fixture()

      registration = %{
        username: profile.username,
        email: user.email,
        password: "short",
        password_confirmation: "shor",
        people_in_household: "",
        newsletter: ""
      }

      conn =
        post(conn, ~p"/api/v1/users/register", %{registration: registration})

      response = json_response(conn, 422)

      assert %{
               "errors" => %{
                 "password" => [
                   "at least one digit or punctuation character",
                   "at least one upper case character",
                   "should be at least 8 character(s)"
                 ],
                 "email" => ["has already been taken"],
                 "newsletter" => ["can't be blank"],
                 "password_confirmation" => ["does not match"],
                 "people_in_household" => ["can't be blank"],
                 "username" => ["has already been taken"]
               }
             } ==
               response
    end
  end

  describe "PUT /api/v1/users/update_password" do
    setup [:register_and_log_in_user]

    @tag :user_controller
    test "updates password when current password is valid and new password is
    valid",
         %{conn: conn, user: user, user_password: user_password} do
      new_password = valid_user_password()

      conn =
        put(conn, ~p"/api/v1/users/update_password", %{
          update_password: %{
            password: user_password,
            new_password: new_password,
            new_password_confirmation: new_password
          }
        })

      assert %{"id" => id} = json_response(conn, 200)["data"]

      user = Accounts.get_user_by_email_and_password(user.email, new_password)

      assert user.id == id
    end

    @tag :user_controller
    test "raises an error on update password when current password don’t match",
         %{conn: conn} do
      wrong_current_password = valid_user_password()
      new_password = valid_user_password()

      conn =
        put(conn, ~p"/api/v1/users/update_password", %{
          update_password: %{
            password: wrong_current_password,
            new_password: new_password,
            new_password_confirmation: new_password
          }
        })

      response = json_response(conn, 422)

      assert %{
               "errors" => %{"current_password" => ["is not valid"]}
             } ==
               response
    end

    @tag :user_controller
    test "raises an error on update password when new password and new password
    confirmation don’t match",
         %{conn: conn, user_password: user_password} do
      new_password = valid_user_password()
      new_password_2 = valid_user_password()

      conn =
        put(conn, ~p"/api/v1/users/update_password", %{
          update_password: %{
            password: user_password,
            new_password: new_password,
            new_password_confirmation: new_password_2
          }
        })

      response = json_response(conn, 422)

      assert %{
               "errors" => %{
                 "password_confirmation" => ["does not match password"]
               }
             } ==
               response
    end

    @tag :user_controller
    test "raises an error on update password when new password don’t meet the
    changeset requirements",
         %{conn: conn, user_password: user_password} do
      new_password = "bépo"

      conn =
        put(conn, ~p"/api/v1/users/update_password", %{
          update_password: %{
            password: user_password,
            new_password: new_password,
            new_password_confirmation: new_password
          }
        })

      response = json_response(conn, 422)

      assert %{
               "errors" => %{
                 "password" => [
                   "at least one digit or punctuation character",
                   "at least one upper case character",
                   "should be at least 8 character(s)"
                 ]
               }
             } ==
               response
    end
  end

  describe "PUT /api/v1/users/update_email" do
    setup [:register_and_log_in_user]

    @tag :user_controller
    test "updates email when current password is valid and new email is
    valid",
         %{conn: conn, user_password: user_password} do
      new_email = unique_user_email()

      conn =
        put(conn, ~p"/api/v1/users/update_email", %{
          update_email: %{
            password: user_password,
            new_email: new_email,
            new_email_confirmation: new_email
          }
        })

      assert %{"id" => id} = json_response(conn, 200)["data"]

      user = Accounts.get_user_by_email_and_password(new_email, user_password)

      assert user.id == id
    end

    @tag :user_controller
    test "raises an error on update email when current password don’t match",
         %{conn: conn} do
      wrong_current_password = valid_user_password()
      new_email = unique_user_email()

      conn =
        put(conn, ~p"/api/v1/users/update_email", %{
          update_email: %{
            password: wrong_current_password,
            new_email: new_email,
            new_email_confirmation: new_email
          }
        })

      response = json_response(conn, 422)

      assert %{
               "errors" => %{"current_password" => ["is not valid"]}
             } ==
               response
    end

    @tag :user_controller
    test "raises an error on update email when new email and new email
    confirmation don’t match",
         %{conn: conn, user_password: user_password} do
      new_email = unique_user_email()
      new_email_2 = unique_user_email()

      conn =
        put(conn, ~p"/api/v1/users/update_email", %{
          update_email: %{
            password: user_password,
            new_email: new_email,
            new_email_confirmation: new_email_2
          }
        })

      response = json_response(conn, 422)

      assert %{
               "errors" => %{"email_confirmation" => ["does not match"]}
             } ==
               response
    end

    @tag :user_controller
    test "raises an error on update email when new email don’t meet the
    changeset requirements",
         %{conn: conn, user_password: user_password} do
      new_email = "invalid_email"

      conn =
        put(conn, ~p"/api/v1/users/update_email", %{
          update_email: %{
            password: user_password,
            new_email: new_email,
            new_email_confirmation: new_email
          }
        })

      response = json_response(conn, 422)

      assert %{
               "errors" => %{
                 "email" => ["must have the @ sign and no spaces"]
               }
             } ==
               response
    end
  end
end