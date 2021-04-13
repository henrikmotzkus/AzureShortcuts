using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Edeka_CostAllocation.Models
{
    public class AllocationKey
    {
        public int Id { get; set; }
        public string KeyID { get; set; }
        public string CostUnit { get; set; }
        public string Month { get; set; }
        public string Year { get; set; }
        public string DistributionShare { get; set; }

        public string ClientID { get; set; }
    }
}
