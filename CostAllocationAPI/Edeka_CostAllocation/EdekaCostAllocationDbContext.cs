using Edeka_CostAllocation.Models;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Edeka_CostAllocation
{
    public class EdekaCostAllocationDbContext : DbContext
    {
        public EdekaCostAllocationDbContext(DbContextOptions<EdekaCostAllocationDbContext> options) : base(options) { }
        public DbSet<AllocationKey> allocationKeys { get; set; }

    }
}
