using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TrueWheels.BEL
{
   public class RegisterParkingAreaBEL
    {
    public int owner_id { get; set; }
     public string Space_type { get; set; }
    public string Property_type { get; set; }
	public string No_of_space { get; set; }
	public string VechileType  { get; set; }
	public string PropertyVerifiedStatus { get; set; }
	public string FacilityGroupId { get; set; }
	public string PropertyAddress { get; set; }
	public int PropertyPinCode { get; set; }
	public string PropertyZone { get; set; }
	public string PropertyLandMark { get; set; }
	 public string OwnerComments { get; set; }
	 public string lattitude { get; set; }
	public string longitude { get; set; }

    public List<string> missingcolumn()
    {
        List<string> clmns = new List<string>();
        return clmns;
    }

    }
}
