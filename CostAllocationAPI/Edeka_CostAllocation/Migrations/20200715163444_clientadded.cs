using Microsoft.EntityFrameworkCore.Migrations;

namespace Edeka_CostAllocation.Migrations
{
    public partial class clientadded : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "ClientID",
                table: "allocationKeys",
                nullable: true);
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "ClientID",
                table: "allocationKeys");
        }
    }
}
