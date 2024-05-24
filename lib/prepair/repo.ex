# RepairPlatform - Cooperative platform to federarate people and companies
# around reparation.

# Copyright (C) 2022 Guillaume Cugnet <guillaume@cugnet.eu>
# Copyright (C) 2022 Jean-Philippe Cugnet <jean-philippe@cugnet.eu>

# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU Affero General Public License as published by the Free
# Software Foundation, version 3 of the License.

# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more
# details.

# You should have received a copy of the GNU Affero General Public License along
# with this program.  If not, see <https://www.gnu.org/licenses/>.

defmodule Prepair.Repo do
  @moduledoc false

  use AshPostgres.Repo,
    otp_app: :prepair

  def installed_extensions do
    ["ash-functions"]
  end
end
