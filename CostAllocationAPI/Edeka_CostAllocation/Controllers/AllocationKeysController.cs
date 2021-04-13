using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Edeka_CostAllocation.Models;
using Microsoft.AspNetCore.Authorization;
using System.Net;
using System.Security.Claims;

namespace Edeka_CostAllocation.Controllers
{

    [Authorize]
    [Route("api/[controller]")]
    [ApiController]
    [Produces("application/json")]
    public class AllocationKeysController : ControllerBase
    {
        // Stores the client id from the oauth token.
        // Requirement is that a client canonly update its own data
        private string clientid;
        private readonly EdekaCostAllocationDbContext _context;

        public AllocationKeysController(EdekaCostAllocationDbContext context)
        {
            _context = context;
        }

        /// <summary>
        /// Gets all allocation keys belonging to a client id
        /// </summary>
        /// <remarks>
        /// Sample request:
        ///
        ///     GET /api/allocationkeys
        ///     {
        ///         "id": 17,
        ///         "keyID": "c4f6ff2b-6286-49de-b624-17b241ac0460",
        ///         "costUnit": "AP-0815-911",
        ///         "month": "07",
        ///         "year": "2020",
        ///         "distributionShare": "50",
        ///         "clientID": "41527672-6020-47d2-b5fa-329c65bdb2db"
        ///     },
        ///      {
        ///         "id": 18,
        ///         "keyID": "c4f6ff2b-6286-49de-b624-17b241ac0460",
        ///         "costUnit": "AP-0815-912",
        ///         "month": "07",
        ///         "year": "2020",
        ///         "distributionShare": "50",
        ///         "clientID": "41527672-6020-47d2-b5fa-329c65bdb2db"
        ///     }
        /// </remarks>
        /// 
        /// <response code="200"> Return a JSON array
        /// 
        /// </response>
        /// <response code="404">Nothing found under this client id</response>  
        [HttpGet]
        public async Task<ActionResult<IEnumerable<AllocationKey>>> GetallocationKeys()
        {

            ValidateAppRole("ReadAll");
            var allocationKey = await _context.allocationKeys.Where(k => k.ClientID.Contains(clientid)).ToListAsync();

            if (allocationKey == null)
            {
                return NotFound();
            }
            return allocationKey;
        }

        /// <summary>
        /// Gets one allocation key with an id only when it belongs to the client id
        /// </summary>
        /// <remarks>
        /// Sample request:
        ///
        ///     GET /api/allocationkeys/5
        ///      {
        ///         "id": 17,
        ///         "keyID": "c4f6ff2b-6286-49de-b624-17b241ac0460",
        ///         "costUnit": "AP-0815-911",
        ///         "month": "07",
        ///         "year": "2020",
        ///         "distributionShare": "50",
        ///         "clientID": "41527672-6020-47d2-b5fa-329c65bdb2db"
        ///     }
        ///     
        /// </remarks>
        /// <response code="200">Returns a JSON object</response>
        /// <response code="404">Nothing found with this id under this client id</response>  
        [HttpGet("{id}")]
        public async Task<ActionResult<AllocationKey>> GetAllocationKey(int id)
        {

            ValidateAppRole("ReadAll");


            var allocationKey = await _context.allocationKeys.FindAsync(id);

            if (allocationKey == null)
            {
                return NotFound();
            }

            if (allocationKey.ClientID == clientid)
            {
                return allocationKey;
            }
            else
            {
                return NotFound();
            }


        }

        /// <summary>
        /// Upates an allocation key only when it belongs to the client id
        /// </summary>
        /// <remarks>
        /// Sample request:
        ///
        ///     PUT /api/allocationkeys/17
        ///     
        ///     {
        ///         "keyID": "c4f6ff2b-6286-49de-b624-17b241ac0460",
        ///         "costUnit": "AP-0815-911",
        ///         "month": "07",
        ///         "year": "2020",
        ///         "distributionShare": "50"
        ///     }
        ///
        /// </remarks>
        /// <response code="200">No content</response>
        /// <response code="400">When id not found</response>  
        /// <response code="500">Bad request when business logic isn't meet</response>  
        [HttpPut("{id}")]
        public async Task<IActionResult> PutAllocationKey(int id, AllocationKey allocationKey)
        {
            if (id != allocationKey.Id)
            {
                return BadRequest();
            }

            _context.Entry(allocationKey).State = EntityState.Modified;

            try
            {
                if (allocationKey.ClientID == clientid)
                {
                    await _context.SaveChangesAsync();
                } else
                {
                    return BadRequest();
                }
            }
            catch (DbUpdateConcurrencyException)
            {
                if (!AllocationKeyExists(id))
                {
                    return NotFound();
                }
                else
                {
                    throw;
                }
            }

            return NoContent();
        }


        /// <summary>
        /// Creates a new allocation key that belong then to a client id
        /// </summary>
        /// <remarks>
        /// Sample request:
        ///
        ///     POST /api/allocationkeys
        ///     {
        ///         "keyID": "c4f6ff2b-6286-49de-b624-17b241ac0460",
        ///         "costUnit": "AP-0815-911",
        ///         "month": "07",
        ///         "year": "2020",
        ///         "distributionShare": "50",
        ///     }
        ///     
        /// </remarks>
        /// <response code="200">Returns the created allocation key JSON object</response>
        [HttpPost]
        public async Task<ActionResult<AllocationKey>> PostAllocationKey(AllocationKey allocationKey)
        {

            ValidateAppRole("ReadAll");
            allocationKey.ClientID = clientid;
            _context.allocationKeys.Add(allocationKey);
            await _context.SaveChangesAsync();
            return CreatedAtAction("GetAllocationKey", new { id = allocationKey.Id }, allocationKey);

        }


        /// <summary>
        /// Creates multiple allocation keys that belings then to a client id
        /// </summary>
        /// <remarks>
        /// Sample request:
        ///
        ///     POST /api/AllocationKeys/allocationkeyarray
        ///     [
        ///      {
        ///         "id": 17,
        ///         "keyID": "c4f6ff2b-6286-49de-b624-17b241ac0460",
        ///         "costUnit": "AP-0815-911",
        ///         "month": "07",
        ///         "year": "2020",
        ///         "distributionShare": "50",
        ///         "clientID": "41527672-6020-47d2-b5fa-329c65bdb2db"
        ///       },
        ///       {
        ///         "id": 17,
        ///         "keyID": "c4f6ff2b-6286-49de-b624-17b241ac0460",
        ///         "costUnit": "AP-0815-911",
        ///         "month": "07",
        ///         "year": "2020",
        ///         "distributionShare": "50",
        ///         "clientID": "41527672-6020-47d2-b5fa-329c65bdb2db"
        ///       }
        ///     ]
        /// </remarks>
        /// <response code="200">Returns the array lenght that was stored</response>
        [HttpPost("allocationkeyarray")]
        public async Task<ActionResult<AllocationKey>> PostAllocationKeyArray([FromBody]AllocationKey[] keys)
        {
            Array.ForEach(keys, (e => 
            {
                e.ClientID = clientid;
                _context.allocationKeys.Add(e);
                _context.SaveChanges();
            }));

            return Ok("Array length " + keys.Count());
        }


        /// <summary>
        /// Deletes an allocation key only when it belongs to the client id
        /// </summary>
        /// <remarks>
        /// Sample request:
        ///
        ///     DELETE /api/allocationkeys/5
        ///     
        /// </remarks>
        /// <response code="200">Returns the deleted allocation key as JSON object</response>
        /// <response code="404">Nothing found with this id under this client id</response> 
        [HttpDelete("{id}")]
        public async Task<ActionResult<AllocationKey>> DeleteAllocationKey(int id)
        {
            ValidateAppRole("ReadAll");
            var allocationKey = await _context.allocationKeys.FindAsync(id);

            //var test= _context.allocationKeys.Where(k => k.ClientID.Contains(clientid).Where().To
            if (allocationKey == null)
            {
                return NotFound();
            }

            
            if (allocationKey.ClientID == clientid)
            {
                _context.allocationKeys.Remove(allocationKey);
                await _context.SaveChangesAsync();
                return allocationKey;

            } else
            {
                return NotFound();
            }
            
        }

        private bool AllocationKeyExists(int id)
        {
            return _context.allocationKeys.Any(e => e.Id == id);
        }

        private void ValidateAppRole(string appRole)
        {

            ClaimsPrincipal cp = this.User;

            string role = cp.Claims.FirstOrDefault(c => c.Type == ClaimTypes.Role).Value;

            if (role != appRole)
            {
                throw new System.Web.Http.HttpResponseException(new System.Net.Http.HttpResponseMessage
                {
                    StatusCode = HttpStatusCode.Unauthorized,
                    ReasonPhrase = $"The 'roles' claim does not contain '{appRole}' or was not found"
                });

            }


            clientid = cp.Claims.FirstOrDefault(c => c.Type == "azp").Value;
            Console.WriteLine("");


        }

    }

}
