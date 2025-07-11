CALL db.labels()


// Count artifacts still using each version of org.jgrapht:jgrapht-core
MATCH (a:Artifact)-[e:relationship_AR]->(r:Release)
WHERE r.id STARTS WITH 'org.jgrapht:jgrapht-core'
RETURN r.version, count(a) AS LibraryUsage
ORDER BY r.version


// Count artifacts using org.jgrapht:jgrapht-core version 1.0.0
MATCH (a:Artifact)-[e:relationship_AR]->(r:Release)
WHERE r.id = 'org.jgrapht:jgrapht-core:1.0.0'
RETURN count(a) AS LU_1_0_0


// Count how many artifacts migrated from version 1.0.0 to any newer version
MATCH (a:Artifact)-[e1:relationship_AR]->(old:Release),
      (a)-[e2:relationship_AR]->(new:Release)
WHERE old.id = 'org.jgrapht:jgrapht-core:1.0.0'
  AND new.id STARTS WITH 'org.jgrapht:jgrapht-core'
  AND old.version < new.version
RETURN count(a) AS DependencyUpdatesFrom_1_0_0


// Find artifacts that migrated from version 1.0.0 to version 1.5.0
MATCH (a:Artifact)-[e1:relationship_AR]->(old:Release),
      (a)-[e2:relationship_AR]->(new:Release)
WHERE old.id = 'org.jgrapht:jgrapht-core:1.0.0'
  AND new.id = 'org.jgrapht:jgrapht-core:1.5.0'
RETURN count(a) AS DU_1_0_0_to_1_5_0


// Main QUERY - 2006 Results


CALL apoc.export.csv.query(
  "MATCH (a:Artifact)-[:relationship_AR]->(release:Release)
   WHERE datetime({epochMillis: release.timestamp}).year = 2006  // Filter releases for the year 2006
   WITH DISTINCT a.id AS LibraryID
   
   // Process each library to collect versions and dependency changes
   MATCH (a:Artifact {id: LibraryID})-[:relationship_AR]->(release:Release)
   WHERE datetime({epochMillis: release.timestamp}).year = 2006  // Ensure release year filter for versions
   WITH LibraryID, release.version AS Version
   ORDER BY LibraryID, toInteger(replace(Version, '.', '')) ASC
   WITH LibraryID, collect(Version) AS versions

   // Loop through versions to find changes between consecutive versions
   UNWIND range(0, size(versions) - 2) AS idx
   WITH LibraryID, versions[idx] AS PreviousVersion, versions[idx + 1] AS NewestVersion

   // Get dependencies for the newest version
   MATCH (a:Artifact {id: LibraryID})-[:relationship_AR]->(newRelease:Release {version: NewestVersion})
   OPTIONAL MATCH (newRelease)-[:dependency]->(newDep:Artifact)
   WITH LibraryID, PreviousVersion, NewestVersion, collect(DISTINCT newDep.id) AS NewDeps

   // Get dependencies for the previous version
   MATCH (a:Artifact {id: LibraryID})-[:relationship_AR]->(oldRelease:Release {version: PreviousVersion})
   OPTIONAL MATCH (oldRelease)-[:dependency]->(oldDep:Artifact)
   WITH LibraryID, PreviousVersion, NewestVersion, 
        NewDeps, 
        collect(DISTINCT oldDep.id) AS OldDeps

   // Calculate added and removed dependencies
   WITH LibraryID, PreviousVersion, NewestVersion, 
        [dep IN NewDeps WHERE NOT dep IN OldDeps] AS AddedDeps, 
        [dep IN OldDeps WHERE NOT dep IN NewDeps] AS RemovedDeps,
        size([dep IN NewDeps WHERE NOT dep IN OldDeps]) AS AddedDepsCount,
        size([dep IN OldDeps WHERE NOT dep IN NewDeps]) AS RemovedDepsCount,
        CASE 
            WHEN size([dep IN NewDeps WHERE NOT dep IN OldDeps]) > 0 OR size([dep IN OldDeps WHERE NOT dep IN NewDeps]) > 0 THEN 'Changed' 
            ELSE 'No Change' 
        END AS Change,
        size([dep IN NewDeps WHERE NOT dep IN OldDeps]) - size([dep IN OldDeps WHERE NOT dep IN NewDeps]) AS NetChange

   RETURN 
       LibraryID, 
       PreviousVersion, 
       NewestVersion, 
       AddedDeps, 
       RemovedDeps, 
       AddedDepsCount, 
       RemovedDepsCount, 
       Change, 
       NetChange",
  
  "file:///all_results_2006_detailed.csv",  // Custom path
  {batchSize: 1000}
)


// Main QUERY - 2007 Results

CALL apoc.export.csv.query(
  "MATCH (a:Artifact)-[:relationship_AR]->(release:Release)
   WHERE datetime({epochMillis: release.timestamp}).year = 2007  // Filter releases for the year 2007
   WITH DISTINCT a.id AS LibraryID
   
   // Process each library to collect versions and dependency changes
   MATCH (a:Artifact {id: LibraryID})-[:relationship_AR]->(release:Release)
   WHERE datetime({epochMillis: release.timestamp}).year = 2007  // Ensure release year filter for versions
   WITH LibraryID, release.version AS Version
   ORDER BY LibraryID, toInteger(replace(Version, '.', '')) ASC
   WITH LibraryID, collect(Version) AS versions

   // Loop through versions to find changes between consecutive versions
   UNWIND range(0, size(versions) - 2) AS idx
   WITH LibraryID, versions[idx] AS PreviousVersion, versions[idx + 1] AS NewestVersion

   // Get dependencies for the newest version
   MATCH (a:Artifact {id: LibraryID})-[:relationship_AR]->(newRelease:Release {version: NewestVersion})
   OPTIONAL MATCH (newRelease)-[:dependency]->(newDep:Artifact)
   WITH LibraryID, PreviousVersion, NewestVersion, collect(DISTINCT newDep.id) AS NewDeps

   // Get dependencies for the previous version
   MATCH (a:Artifact {id: LibraryID})-[:relationship_AR]->(oldRelease:Release {version: PreviousVersion})
   OPTIONAL MATCH (oldRelease)-[:dependency]->(oldDep:Artifact)
   WITH LibraryID, PreviousVersion, NewestVersion, 
        NewDeps, 
        collect(DISTINCT oldDep.id) AS OldDeps

   // Calculate added and removed dependencies
   WITH LibraryID, PreviousVersion, NewestVersion, 
        [dep IN NewDeps WHERE NOT dep IN OldDeps] AS AddedDeps, 
        [dep IN OldDeps WHERE NOT dep IN NewDeps] AS RemovedDeps,
        size([dep IN NewDeps WHERE NOT dep IN OldDeps]) AS AddedDepsCount,
        size([dep IN OldDeps WHERE NOT dep IN NewDeps]) AS RemovedDepsCount,
        CASE 
            WHEN size([dep IN NewDeps WHERE NOT dep IN OldDeps]) > 0 OR size([dep IN OldDeps WHERE NOT dep IN NewDeps]) > 0 THEN 'Changed' 
            ELSE 'No Change' 
        END AS Change,
        size([dep IN NewDeps WHERE NOT dep IN OldDeps]) - size([dep IN OldDeps WHERE NOT dep IN NewDeps]) AS NetChange

   RETURN 
       LibraryID, 
       PreviousVersion, 
       NewestVersion, 
       AddedDeps, 
       RemovedDeps, 
       AddedDepsCount, 
       RemovedDepsCount, 
       Change, 
       NetChange",
  
  "file:///all_results_2007_detailed.csv",  // Save to this path
  {batchSize: 1000}
)



// Main QUERY - 2008 Results

CALL apoc.export.csv.query(
  "MATCH (a:Artifact)-[:relationship_AR]->(release:Release)
   WHERE datetime({epochMillis: release.timestamp}).year = 2008  // Filter releases for the year 2007
   WITH DISTINCT a.id AS LibraryID
   
   // Process each library to collect versions and dependency changes
   MATCH (a:Artifact {id: LibraryID})-[:relationship_AR]->(release:Release)
   WHERE datetime({epochMillis: release.timestamp}).year = 2008  // Ensure release year filter for versions
   WITH LibraryID, release.version AS Version
   ORDER BY LibraryID, toInteger(replace(Version, '.', '')) ASC
   WITH LibraryID, collect(Version) AS versions

   // Loop through versions to find changes between consecutive versions
   UNWIND range(0, size(versions) - 2) AS idx
   WITH LibraryID, versions[idx] AS PreviousVersion, versions[idx + 1] AS NewestVersion

   // Get dependencies for the newest version
   MATCH (a:Artifact {id: LibraryID})-[:relationship_AR]->(newRelease:Release {version: NewestVersion})
   OPTIONAL MATCH (newRelease)-[:dependency]->(newDep:Artifact)
   WITH LibraryID, PreviousVersion, NewestVersion, collect(DISTINCT newDep.id) AS NewDeps

   // Get dependencies for the previous version
   MATCH (a:Artifact {id: LibraryID})-[:relationship_AR]->(oldRelease:Release {version: PreviousVersion})
   OPTIONAL MATCH (oldRelease)-[:dependency]->(oldDep:Artifact)
   WITH LibraryID, PreviousVersion, NewestVersion, 
        NewDeps, 
        collect(DISTINCT oldDep.id) AS OldDeps

   // Calculate added and removed dependencies
   WITH LibraryID, PreviousVersion, NewestVersion, 
        [dep IN NewDeps WHERE NOT dep IN OldDeps] AS AddedDeps, 
        [dep IN OldDeps WHERE NOT dep IN NewDeps] AS RemovedDeps,
        size([dep IN NewDeps WHERE NOT dep IN OldDeps]) AS AddedDepsCount,
        size([dep IN OldDeps WHERE NOT dep IN NewDeps]) AS RemovedDepsCount,
        CASE 
            WHEN size([dep IN NewDeps WHERE NOT dep IN OldDeps]) > 0 OR size([dep IN OldDeps WHERE NOT dep IN NewDeps]) > 0 THEN 'Changed' 
            ELSE 'No Change' 
        END AS Change,
        size([dep IN NewDeps WHERE NOT dep IN OldDeps]) - size([dep IN OldDeps WHERE NOT dep IN NewDeps]) AS NetChange

   RETURN 
       LibraryID, 
       PreviousVersion, 
       NewestVersion, 
       AddedDeps, 
       RemovedDeps, 
       AddedDepsCount, 
       RemovedDepsCount, 
       Change, 
       NetChange",
  
  "file:///all_results_2008_detailed.csv",  // Save to this path
  {batchSize: 1000}
)



// Main QUERY - 2009 Results

CALL apoc.export.csv.query(
  "MATCH (a:Artifact)-[:relationship_AR]->(release:Release)
   WHERE datetime({epochMillis: release.timestamp}).year = 2009  // Filter releases for the year 2007
   WITH DISTINCT a.id AS LibraryID
   
   // Process each library to collect versions and dependency changes
   MATCH (a:Artifact {id: LibraryID})-[:relationship_AR]->(release:Release)
   WHERE datetime({epochMillis: release.timestamp}).year = 2009  // Ensure release year filter for versions
   WITH LibraryID, release.version AS Version
   ORDER BY LibraryID, toInteger(replace(Version, '.', '')) ASC
   WITH LibraryID, collect(Version) AS versions

   // Loop through versions to find changes between consecutive versions
   UNWIND range(0, size(versions) - 2) AS idx
   WITH LibraryID, versions[idx] AS PreviousVersion, versions[idx + 1] AS NewestVersion

   // Get dependencies for the newest version
   MATCH (a:Artifact {id: LibraryID})-[:relationship_AR]->(newRelease:Release {version: NewestVersion})
   OPTIONAL MATCH (newRelease)-[:dependency]->(newDep:Artifact)
   WITH LibraryID, PreviousVersion, NewestVersion, collect(DISTINCT newDep.id) AS NewDeps

   // Get dependencies for the previous version
   MATCH (a:Artifact {id: LibraryID})-[:relationship_AR]->(oldRelease:Release {version: PreviousVersion})
   OPTIONAL MATCH (oldRelease)-[:dependency]->(oldDep:Artifact)
   WITH LibraryID, PreviousVersion, NewestVersion, 
        NewDeps, 
        collect(DISTINCT oldDep.id) AS OldDeps

   // Calculate added and removed dependencies
   WITH LibraryID, PreviousVersion, NewestVersion, 
        [dep IN NewDeps WHERE NOT dep IN OldDeps] AS AddedDeps, 
        [dep IN OldDeps WHERE NOT dep IN NewDeps] AS RemovedDeps,
        size([dep IN NewDeps WHERE NOT dep IN OldDeps]) AS AddedDepsCount,
        size([dep IN OldDeps WHERE NOT dep IN NewDeps]) AS RemovedDepsCount,
        CASE 
            WHEN size([dep IN NewDeps WHERE NOT dep IN OldDeps]) > 0 OR size([dep IN OldDeps WHERE NOT dep IN NewDeps]) > 0 THEN 'Changed' 
            ELSE 'No Change' 
        END AS Change,
        size([dep IN NewDeps WHERE NOT dep IN OldDeps]) - size([dep IN OldDeps WHERE NOT dep IN NewDeps]) AS NetChange

   RETURN 
       LibraryID, 
       PreviousVersion, 
       NewestVersion, 
       AddedDeps, 
       RemovedDeps, 
       AddedDepsCount, 
       RemovedDepsCount, 
       Change, 
       NetChange",
  
  "file:///all_results_2009_detailed.csv",  // Save to this path
  {batchSize: 1000}
)



// Main QUERY - 2010 Results

CALL apoc.export.csv.query(
  "MATCH (a:Artifact)-[:relationship_AR]->(release:Release)
   WHERE datetime({epochMillis: release.timestamp}).year = 2010  // Filter releases for the year 2007
   WITH DISTINCT a.id AS LibraryID
   
   // Process each library to collect versions and dependency changes
   MATCH (a:Artifact {id: LibraryID})-[:relationship_AR]->(release:Release)
   WHERE datetime({epochMillis: release.timestamp}).year = 2010  // Ensure release year filter for versions
   WITH LibraryID, release.version AS Version
   ORDER BY LibraryID, toInteger(replace(Version, '.', '')) ASC
   WITH LibraryID, collect(Version) AS versions

   // Loop through versions to find changes between consecutive versions
   UNWIND range(0, size(versions) - 2) AS idx
   WITH LibraryID, versions[idx] AS PreviousVersion, versions[idx + 1] AS NewestVersion

   // Get dependencies for the newest version
   MATCH (a:Artifact {id: LibraryID})-[:relationship_AR]->(newRelease:Release {version: NewestVersion})
   OPTIONAL MATCH (newRelease)-[:dependency]->(newDep:Artifact)
   WITH LibraryID, PreviousVersion, NewestVersion, collect(DISTINCT newDep.id) AS NewDeps

   // Get dependencies for the previous version
   MATCH (a:Artifact {id: LibraryID})-[:relationship_AR]->(oldRelease:Release {version: PreviousVersion})
   OPTIONAL MATCH (oldRelease)-[:dependency]->(oldDep:Artifact)
   WITH LibraryID, PreviousVersion, NewestVersion, 
        NewDeps, 
        collect(DISTINCT oldDep.id) AS OldDeps

   // Calculate added and removed dependencies
   WITH LibraryID, PreviousVersion, NewestVersion, 
        [dep IN NewDeps WHERE NOT dep IN OldDeps] AS AddedDeps, 
        [dep IN OldDeps WHERE NOT dep IN NewDeps] AS RemovedDeps,
        size([dep IN NewDeps WHERE NOT dep IN OldDeps]) AS AddedDepsCount,
        size([dep IN OldDeps WHERE NOT dep IN NewDeps]) AS RemovedDepsCount,
        CASE 
            WHEN size([dep IN NewDeps WHERE NOT dep IN OldDeps]) > 0 OR size([dep IN OldDeps WHERE NOT dep IN NewDeps]) > 0 THEN 'Changed' 
            ELSE 'No Change' 
        END AS Change,
        size([dep IN NewDeps WHERE NOT dep IN OldDeps]) - size([dep IN OldDeps WHERE NOT dep IN NewDeps]) AS NetChange

   RETURN 
       LibraryID, 
       PreviousVersion, 
       NewestVersion, 
       AddedDeps, 
       RemovedDeps, 
       AddedDepsCount, 
       RemovedDepsCount, 
       Change, 
       NetChange",
  
  "file:///all_results_2010_detailed.csv",  // Save to this path
  {batchSize: 1000}
)



// Main QUERY - 2011 Results

CALL apoc.export.csv.query(
  "MATCH (a:Artifact)-[:relationship_AR]->(release:Release)
   WHERE datetime({epochMillis: release.timestamp}).year = 2011  // Filter releases for the year 2007
   WITH DISTINCT a.id AS LibraryID
   
   // Process each library to collect versions and dependency changes
   MATCH (a:Artifact {id: LibraryID})-[:relationship_AR]->(release:Release)
   WHERE datetime({epochMillis: release.timestamp}).year = 2011  // Ensure release year filter for versions
   WITH LibraryID, release.version AS Version
   ORDER BY LibraryID, toInteger(replace(Version, '.', '')) ASC
   WITH LibraryID, collect(Version) AS versions

   // Loop through versions to find changes between consecutive versions
   UNWIND range(0, size(versions) - 2) AS idx
   WITH LibraryID, versions[idx] AS PreviousVersion, versions[idx + 1] AS NewestVersion

   // Get dependencies for the newest version
   MATCH (a:Artifact {id: LibraryID})-[:relationship_AR]->(newRelease:Release {version: NewestVersion})
   OPTIONAL MATCH (newRelease)-[:dependency]->(newDep:Artifact)
   WITH LibraryID, PreviousVersion, NewestVersion, collect(DISTINCT newDep.id) AS NewDeps

   // Get dependencies for the previous version
   MATCH (a:Artifact {id: LibraryID})-[:relationship_AR]->(oldRelease:Release {version: PreviousVersion})
   OPTIONAL MATCH (oldRelease)-[:dependency]->(oldDep:Artifact)
   WITH LibraryID, PreviousVersion, NewestVersion, 
        NewDeps, 
        collect(DISTINCT oldDep.id) AS OldDeps

   // Calculate added and removed dependencies
   WITH LibraryID, PreviousVersion, NewestVersion, 
        [dep IN NewDeps WHERE NOT dep IN OldDeps] AS AddedDeps, 
        [dep IN OldDeps WHERE NOT dep IN NewDeps] AS RemovedDeps,
        size([dep IN NewDeps WHERE NOT dep IN OldDeps]) AS AddedDepsCount,
        size([dep IN OldDeps WHERE NOT dep IN NewDeps]) AS RemovedDepsCount,
        CASE 
            WHEN size([dep IN NewDeps WHERE NOT dep IN OldDeps]) > 0 OR size([dep IN OldDeps WHERE NOT dep IN NewDeps]) > 0 THEN 'Changed' 
            ELSE 'No Change' 
        END AS Change,
        size([dep IN NewDeps WHERE NOT dep IN OldDeps]) - size([dep IN OldDeps WHERE NOT dep IN NewDeps]) AS NetChange

   RETURN 
       LibraryID, 
       PreviousVersion, 
       NewestVersion, 
       AddedDeps, 
       RemovedDeps, 
       AddedDepsCount, 
       RemovedDepsCount, 
       Change, 
       NetChange",
  
  "file:///all_results_2011_detailed.csv",  // Save to this path
  {batchSize: 1000}
)



// Main QUERY - 2012 Results

CALL apoc.export.csv.query(
  "MATCH (a:Artifact)-[:relationship_AR]->(release:Release)
   WHERE datetime({epochMillis: release.timestamp}).year = 2012  // Filter releases for the year 2007
   WITH DISTINCT a.id AS LibraryID
   
   // Process each library to collect versions and dependency changes
   MATCH (a:Artifact {id: LibraryID})-[:relationship_AR]->(release:Release)
   WHERE datetime({epochMillis: release.timestamp}).year = 2012  // Ensure release year filter for versions
   WITH LibraryID, release.version AS Version
   ORDER BY LibraryID, toInteger(replace(Version, '.', '')) ASC
   WITH LibraryID, collect(Version) AS versions

   // Loop through versions to find changes between consecutive versions
   UNWIND range(0, size(versions) - 2) AS idx
   WITH LibraryID, versions[idx] AS PreviousVersion, versions[idx + 1] AS NewestVersion

   // Get dependencies for the newest version
   MATCH (a:Artifact {id: LibraryID})-[:relationship_AR]->(newRelease:Release {version: NewestVersion})
   OPTIONAL MATCH (newRelease)-[:dependency]->(newDep:Artifact)
   WITH LibraryID, PreviousVersion, NewestVersion, collect(DISTINCT newDep.id) AS NewDeps

   // Get dependencies for the previous version
   MATCH (a:Artifact {id: LibraryID})-[:relationship_AR]->(oldRelease:Release {version: PreviousVersion})
   OPTIONAL MATCH (oldRelease)-[:dependency]->(oldDep:Artifact)
   WITH LibraryID, PreviousVersion, NewestVersion, 
        NewDeps, 
        collect(DISTINCT oldDep.id) AS OldDeps

   // Calculate added and removed dependencies
   WITH LibraryID, PreviousVersion, NewestVersion, 
        [dep IN NewDeps WHERE NOT dep IN OldDeps] AS AddedDeps, 
        [dep IN OldDeps WHERE NOT dep IN NewDeps] AS RemovedDeps,
        size([dep IN NewDeps WHERE NOT dep IN OldDeps]) AS AddedDepsCount,
        size([dep IN OldDeps WHERE NOT dep IN NewDeps]) AS RemovedDepsCount,
        CASE 
            WHEN size([dep IN NewDeps WHERE NOT dep IN OldDeps]) > 0 OR size([dep IN OldDeps WHERE NOT dep IN NewDeps]) > 0 THEN 'Changed' 
            ELSE 'No Change' 
        END AS Change,
        size([dep IN NewDeps WHERE NOT dep IN OldDeps]) - size([dep IN OldDeps WHERE NOT dep IN NewDeps]) AS NetChange

   RETURN 
       LibraryID, 
       PreviousVersion, 
       NewestVersion, 
       AddedDeps, 
       RemovedDeps, 
       AddedDepsCount, 
       RemovedDepsCount, 
       Change, 
       NetChange",
  
  "file:///all_results_2012_detailed.csv",  // Save to this path
  {batchSize: 1000}
)



// Main QUERY - 2013 Results

CALL apoc.export.csv.query(
  "MATCH (a:Artifact)-[:relationship_AR]->(release:Release)
   WHERE datetime({epochMillis: release.timestamp}).year = 2013  // Filter releases for the year 2007
   WITH DISTINCT a.id AS LibraryID
   
   // Process each library to collect versions and dependency changes
   MATCH (a:Artifact {id: LibraryID})-[:relationship_AR]->(release:Release)
   WHERE datetime({epochMillis: release.timestamp}).year = 2013  // Ensure release year filter for versions
   WITH LibraryID, release.version AS Version
   ORDER BY LibraryID, toInteger(replace(Version, '.', '')) ASC
   WITH LibraryID, collect(Version) AS versions

   // Loop through versions to find changes between consecutive versions
   UNWIND range(0, size(versions) - 2) AS idx
   WITH LibraryID, versions[idx] AS PreviousVersion, versions[idx + 1] AS NewestVersion

   // Get dependencies for the newest version
   MATCH (a:Artifact {id: LibraryID})-[:relationship_AR]->(newRelease:Release {version: NewestVersion})
   OPTIONAL MATCH (newRelease)-[:dependency]->(newDep:Artifact)
   WITH LibraryID, PreviousVersion, NewestVersion, collect(DISTINCT newDep.id) AS NewDeps

   // Get dependencies for the previous version
   MATCH (a:Artifact {id: LibraryID})-[:relationship_AR]->(oldRelease:Release {version: PreviousVersion})
   OPTIONAL MATCH (oldRelease)-[:dependency]->(oldDep:Artifact)
   WITH LibraryID, PreviousVersion, NewestVersion, 
        NewDeps, 
        collect(DISTINCT oldDep.id) AS OldDeps

   // Calculate added and removed dependencies
   WITH LibraryID, PreviousVersion, NewestVersion, 
        [dep IN NewDeps WHERE NOT dep IN OldDeps] AS AddedDeps, 
        [dep IN OldDeps WHERE NOT dep IN NewDeps] AS RemovedDeps,
        size([dep IN NewDeps WHERE NOT dep IN OldDeps]) AS AddedDepsCount,
        size([dep IN OldDeps WHERE NOT dep IN NewDeps]) AS RemovedDepsCount,
        CASE 
            WHEN size([dep IN NewDeps WHERE NOT dep IN OldDeps]) > 0 OR size([dep IN OldDeps WHERE NOT dep IN NewDeps]) > 0 THEN 'Changed' 
            ELSE 'No Change' 
        END AS Change,
        size([dep IN NewDeps WHERE NOT dep IN OldDeps]) - size([dep IN OldDeps WHERE NOT dep IN NewDeps]) AS NetChange

   RETURN 
       LibraryID, 
       PreviousVersion, 
       NewestVersion, 
       AddedDeps, 
       RemovedDeps, 
       AddedDepsCount, 
       RemovedDepsCount, 
       Change, 
       NetChange",
  
  "file:///all_results_2013_detailed.csv",  // Save to this path
  {batchSize: 1000}
)



// Main QUERY - 2014 Results

CALL apoc.export.csv.query(
  "MATCH (a:Artifact)-[:relationship_AR]->(release:Release)
   WHERE datetime({epochMillis: release.timestamp}).year = 2014  // Filter releases for the year 2007
   WITH DISTINCT a.id AS LibraryID
   
   // Process each library to collect versions and dependency changes
   MATCH (a:Artifact {id: LibraryID})-[:relationship_AR]->(release:Release)
   WHERE datetime({epochMillis: release.timestamp}).year = 2014  // Ensure release year filter for versions
   WITH LibraryID, release.version AS Version
   ORDER BY LibraryID, toFloat(replace(Version, '.', '')) ASC  // Use toFloat to avoid integer overflow
   WITH LibraryID, collect(Version) AS versions

   // Loop through versions to find changes between consecutive versions
   UNWIND range(0, size(versions) - 2) AS idx
   WITH LibraryID, versions[idx] AS PreviousVersion, versions[idx + 1] AS NewestVersion

   // Get dependencies for the newest version
   MATCH (a:Artifact {id: LibraryID})-[:relationship_AR]->(newRelease:Release {version: NewestVersion})
   OPTIONAL MATCH (newRelease)-[:dependency]->(newDep:Artifact)
   WITH LibraryID, PreviousVersion, NewestVersion, collect(DISTINCT newDep.id) AS NewDeps

   // Get dependencies for the previous version
   MATCH (a:Artifact {id: LibraryID})-[:relationship_AR]->(oldRelease:Release {version: PreviousVersion})
   OPTIONAL MATCH (oldRelease)-[:dependency]->(oldDep:Artifact)
   WITH LibraryID, PreviousVersion, NewestVersion, 
        NewDeps, 
        collect(DISTINCT oldDep.id) AS OldDeps

   // Calculate added and removed dependencies
   WITH LibraryID, PreviousVersion, NewestVersion, 
        [dep IN NewDeps WHERE NOT dep IN OldDeps] AS AddedDeps, 
        [dep IN OldDeps WHERE NOT dep IN NewDeps] AS RemovedDeps,
        size([dep IN NewDeps WHERE NOT dep IN OldDeps]) AS AddedDepsCount,
        size([dep IN OldDeps WHERE NOT dep IN NewDeps]) AS RemovedDepsCount,
        CASE 
            WHEN size([dep IN NewDeps WHERE NOT dep IN OldDeps]) > 0 OR size([dep IN OldDeps WHERE NOT dep IN NewDeps]) > 0 THEN 'Changed' 
            ELSE 'No Change' 
        END AS Change,
        size([dep IN NewDeps WHERE NOT dep IN OldDeps]) - size([dep IN OldDeps WHERE NOT dep IN NewDeps]) AS NetChange

   RETURN 
       LibraryID, 
       PreviousVersion, 
       NewestVersion, 
       AddedDeps, 
       RemovedDeps, 
       AddedDepsCount, 
       RemovedDepsCount, 
       Change, 
       NetChange",
  
  "file:///all_results_2014_detailed.csv",  // Save to this path
  {batchSize: 1000}
)


// Main QUERY - 2015 Results

CALL apoc.export.csv.query(
  "MATCH (a:Artifact)-[:relationship_AR]->(release:Release)
   WHERE datetime({epochMillis: release.timestamp}).year = 2015  // Filter releases for the year 2007
   WITH DISTINCT a.id AS LibraryID
   
   // Process each library to collect versions and dependency changes
   MATCH (a:Artifact {id: LibraryID})-[:relationship_AR]->(release:Release)
   WHERE datetime({epochMillis: release.timestamp}).year = 2015  // Ensure release year filter for versions
   WITH LibraryID, release.version AS Version
   ORDER BY LibraryID, toFloat(replace(Version, '.', '')) ASC  // Use toFloat to avoid integer overflow
   WITH LibraryID, collect(Version) AS versions

   // Loop through versions to find changes between consecutive versions
   UNWIND range(0, size(versions) - 2) AS idx
   WITH LibraryID, versions[idx] AS PreviousVersion, versions[idx + 1] AS NewestVersion

   // Get dependencies for the newest version
   MATCH (a:Artifact {id: LibraryID})-[:relationship_AR]->(newRelease:Release {version: NewestVersion})
   OPTIONAL MATCH (newRelease)-[:dependency]->(newDep:Artifact)
   WITH LibraryID, PreviousVersion, NewestVersion, collect(DISTINCT newDep.id) AS NewDeps

   // Get dependencies for the previous version
   MATCH (a:Artifact {id: LibraryID})-[:relationship_AR]->(oldRelease:Release {version: PreviousVersion})
   OPTIONAL MATCH (oldRelease)-[:dependency]->(oldDep:Artifact)
   WITH LibraryID, PreviousVersion, NewestVersion, 
        NewDeps, 
        collect(DISTINCT oldDep.id) AS OldDeps

   // Calculate added and removed dependencies
   WITH LibraryID, PreviousVersion, NewestVersion, 
        [dep IN NewDeps WHERE NOT dep IN OldDeps] AS AddedDeps, 
        [dep IN OldDeps WHERE NOT dep IN NewDeps] AS RemovedDeps,
        size([dep IN NewDeps WHERE NOT dep IN OldDeps]) AS AddedDepsCount,
        size([dep IN OldDeps WHERE NOT dep IN NewDeps]) AS RemovedDepsCount,
        CASE 
            WHEN size([dep IN NewDeps WHERE NOT dep IN OldDeps]) > 0 OR size([dep IN OldDeps WHERE NOT dep IN NewDeps]) > 0 THEN 'Changed' 
            ELSE 'No Change' 
        END AS Change,
        size([dep IN NewDeps WHERE NOT dep IN OldDeps]) - size([dep IN OldDeps WHERE NOT dep IN NewDeps]) AS NetChange

   RETURN 
       LibraryID, 
       PreviousVersion, 
       NewestVersion, 
       AddedDeps, 
       RemovedDeps, 
       AddedDepsCount, 
       RemovedDepsCount, 
       Change, 
       NetChange",
  
  "file:///all_results_2015_detailed.csv",  // Save to this path
  {batchSize: 1000}
)


// Main QUERY - 2016 Results

CALL apoc.export.csv.query(
  "MATCH (a:Artifact)-[:relationship_AR]->(release:Release)
   WHERE datetime({epochMillis: release.timestamp}).year = 2016  // Filter releases for the year 2007
   WITH DISTINCT a.id AS LibraryID
   
   // Process each library to collect versions and dependency changes
   MATCH (a:Artifact {id: LibraryID})-[:relationship_AR]->(release:Release)
   WHERE datetime({epochMillis: release.timestamp}).year = 2016  // Ensure release year filter for versions
   WITH LibraryID, release.version AS Version
   ORDER BY LibraryID, toFloat(replace(Version, '.', '')) ASC  // Use toFloat to avoid integer overflow
   WITH LibraryID, collect(Version) AS versions

   // Loop through versions to find changes between consecutive versions
   UNWIND range(0, size(versions) - 2) AS idx
   WITH LibraryID, versions[idx] AS PreviousVersion, versions[idx + 1] AS NewestVersion

   // Get dependencies for the newest version
   MATCH (a:Artifact {id: LibraryID})-[:relationship_AR]->(newRelease:Release {version: NewestVersion})
   OPTIONAL MATCH (newRelease)-[:dependency]->(newDep:Artifact)
   WITH LibraryID, PreviousVersion, NewestVersion, collect(DISTINCT newDep.id) AS NewDeps

   // Get dependencies for the previous version
   MATCH (a:Artifact {id: LibraryID})-[:relationship_AR]->(oldRelease:Release {version: PreviousVersion})
   OPTIONAL MATCH (oldRelease)-[:dependency]->(oldDep:Artifact)
   WITH LibraryID, PreviousVersion, NewestVersion, 
        NewDeps, 
        collect(DISTINCT oldDep.id) AS OldDeps

   // Calculate added and removed dependencies
   WITH LibraryID, PreviousVersion, NewestVersion, 
        [dep IN NewDeps WHERE NOT dep IN OldDeps] AS AddedDeps, 
        [dep IN OldDeps WHERE NOT dep IN NewDeps] AS RemovedDeps,
        size([dep IN NewDeps WHERE NOT dep IN OldDeps]) AS AddedDepsCount,
        size([dep IN OldDeps WHERE NOT dep IN NewDeps]) AS RemovedDepsCount,
        CASE 
            WHEN size([dep IN NewDeps WHERE NOT dep IN OldDeps]) > 0 OR size([dep IN OldDeps WHERE NOT dep IN NewDeps]) > 0 THEN 'Changed' 
            ELSE 'No Change' 
        END AS Change,
        size([dep IN NewDeps WHERE NOT dep IN OldDeps]) - size([dep IN OldDeps WHERE NOT dep IN NewDeps]) AS NetChange

   RETURN 
       LibraryID, 
       PreviousVersion, 
       NewestVersion, 
       AddedDeps, 
       RemovedDeps, 
       AddedDepsCount, 
       RemovedDepsCount, 
       Change, 
       NetChange",
  
  "file:///all_results_2016_detailed.csv",  // Save to this path
  {batchSize: 1000}
)


// Main QUERY - 2017 Results

CALL apoc.export.csv.query(
  "MATCH (a:Artifact)-[:relationship_AR]->(release:Release)
   WHERE datetime({epochMillis: release.timestamp}).year = 2017  // Filter releases for the year 2007
   WITH DISTINCT a.id AS LibraryID
   
   // Process each library to collect versions and dependency changes
   MATCH (a:Artifact {id: LibraryID})-[:relationship_AR]->(release:Release)
   WHERE datetime({epochMillis: release.timestamp}).year = 2017  // Ensure release year filter for versions
   WITH LibraryID, release.version AS Version
   ORDER BY LibraryID, toFloat(replace(Version, '.', '')) ASC  // Use toFloat to avoid integer overflow
   WITH LibraryID, collect(Version) AS versions

   // Loop through versions to find changes between consecutive versions
   UNWIND range(0, size(versions) - 2) AS idx
   WITH LibraryID, versions[idx] AS PreviousVersion, versions[idx + 1] AS NewestVersion

   // Get dependencies for the newest version
   MATCH (a:Artifact {id: LibraryID})-[:relationship_AR]->(newRelease:Release {version: NewestVersion})
   OPTIONAL MATCH (newRelease)-[:dependency]->(newDep:Artifact)
   WITH LibraryID, PreviousVersion, NewestVersion, collect(DISTINCT newDep.id) AS NewDeps

   // Get dependencies for the previous version
   MATCH (a:Artifact {id: LibraryID})-[:relationship_AR]->(oldRelease:Release {version: PreviousVersion})
   OPTIONAL MATCH (oldRelease)-[:dependency]->(oldDep:Artifact)
   WITH LibraryID, PreviousVersion, NewestVersion, 
        NewDeps, 
        collect(DISTINCT oldDep.id) AS OldDeps

   // Calculate added and removed dependencies
   WITH LibraryID, PreviousVersion, NewestVersion, 
        [dep IN NewDeps WHERE NOT dep IN OldDeps] AS AddedDeps, 
        [dep IN OldDeps WHERE NOT dep IN NewDeps] AS RemovedDeps,
        size([dep IN NewDeps WHERE NOT dep IN OldDeps]) AS AddedDepsCount,
        size([dep IN OldDeps WHERE NOT dep IN NewDeps]) AS RemovedDepsCount,
        CASE 
            WHEN size([dep IN NewDeps WHERE NOT dep IN OldDeps]) > 0 OR size([dep IN OldDeps WHERE NOT dep IN NewDeps]) > 0 THEN 'Changed' 
            ELSE 'No Change' 
        END AS Change,
        size([dep IN NewDeps WHERE NOT dep IN OldDeps]) - size([dep IN OldDeps WHERE NOT dep IN NewDeps]) AS NetChange

   RETURN 
       LibraryID, 
       PreviousVersion, 
       NewestVersion, 
       AddedDeps, 
       RemovedDeps, 
       AddedDepsCount, 
       RemovedDepsCount, 
       Change, 
       NetChange",
  
  "file:///all_results_2017_detailed.csv",  // Save to this path
  {batchSize: 1000}
)


// Main QUERY - 2018 Results

CALL apoc.export.csv.query(
  "MATCH (a:Artifact)-[:relationship_AR]->(release:Release)
   WHERE datetime({epochMillis: release.timestamp}).year = 2018  // Filter releases for the year 2007
   WITH DISTINCT a.id AS LibraryID
   
   // Process each library to collect versions and dependency changes
   MATCH (a:Artifact {id: LibraryID})-[:relationship_AR]->(release:Release)
   WHERE datetime({epochMillis: release.timestamp}).year = 2018  // Ensure release year filter for versions
   WITH LibraryID, release.version AS Version
   ORDER BY LibraryID, toFloat(replace(Version, '.', '')) ASC  // Use toFloat to avoid integer overflow
   WITH LibraryID, collect(Version) AS versions

   // Loop through versions to find changes between consecutive versions
   UNWIND range(0, size(versions) - 2) AS idx
   WITH LibraryID, versions[idx] AS PreviousVersion, versions[idx + 1] AS NewestVersion

   // Get dependencies for the newest version
   MATCH (a:Artifact {id: LibraryID})-[:relationship_AR]->(newRelease:Release {version: NewestVersion})
   OPTIONAL MATCH (newRelease)-[:dependency]->(newDep:Artifact)
   WITH LibraryID, PreviousVersion, NewestVersion, collect(DISTINCT newDep.id) AS NewDeps

   // Get dependencies for the previous version
   MATCH (a:Artifact {id: LibraryID})-[:relationship_AR]->(oldRelease:Release {version: PreviousVersion})
   OPTIONAL MATCH (oldRelease)-[:dependency]->(oldDep:Artifact)
   WITH LibraryID, PreviousVersion, NewestVersion, 
        NewDeps, 
        collect(DISTINCT oldDep.id) AS OldDeps

   // Calculate added and removed dependencies
   WITH LibraryID, PreviousVersion, NewestVersion, 
        [dep IN NewDeps WHERE NOT dep IN OldDeps] AS AddedDeps, 
        [dep IN OldDeps WHERE NOT dep IN NewDeps] AS RemovedDeps,
        size([dep IN NewDeps WHERE NOT dep IN OldDeps]) AS AddedDepsCount,
        size([dep IN OldDeps WHERE NOT dep IN NewDeps]) AS RemovedDepsCount,
        CASE 
            WHEN size([dep IN NewDeps WHERE NOT dep IN OldDeps]) > 0 OR size([dep IN OldDeps WHERE NOT dep IN NewDeps]) > 0 THEN 'Changed' 
            ELSE 'No Change' 
        END AS Change,
        size([dep IN NewDeps WHERE NOT dep IN OldDeps]) - size([dep IN OldDeps WHERE NOT dep IN NewDeps]) AS NetChange

   RETURN 
       LibraryID, 
       PreviousVersion, 
       NewestVersion, 
       AddedDeps, 
       RemovedDeps, 
       AddedDepsCount, 
       RemovedDepsCount, 
       Change, 
       NetChange",
  
  "file:///all_results_2018_detailed.csv",  // Save to this path
  {batchSize: 1000}
)


// Main QUERY - 2019 Results

CALL apoc.export.csv.query(
  "MATCH (a:Artifact)-[:relationship_AR]->(release:Release)
   WHERE datetime({epochMillis: release.timestamp}).year = 2019  // Filter releases for the year 2007
   WITH DISTINCT a.id AS LibraryID
   
   // Process each library to collect versions and dependency changes
   MATCH (a:Artifact {id: LibraryID})-[:relationship_AR]->(release:Release)
   WHERE datetime({epochMillis: release.timestamp}).year = 2019  // Ensure release year filter for versions
   WITH LibraryID, release.version AS Version
   ORDER BY LibraryID, toFloat(replace(Version, '.', '')) ASC  // Use toFloat to avoid integer overflow
   WITH LibraryID, collect(Version) AS versions

   // Loop through versions to find changes between consecutive versions
   UNWIND range(0, size(versions) - 2) AS idx
   WITH LibraryID, versions[idx] AS PreviousVersion, versions[idx + 1] AS NewestVersion

   // Get dependencies for the newest version
   MATCH (a:Artifact {id: LibraryID})-[:relationship_AR]->(newRelease:Release {version: NewestVersion})
   OPTIONAL MATCH (newRelease)-[:dependency]->(newDep:Artifact)
   WITH LibraryID, PreviousVersion, NewestVersion, collect(DISTINCT newDep.id) AS NewDeps

   // Get dependencies for the previous version
   MATCH (a:Artifact {id: LibraryID})-[:relationship_AR]->(oldRelease:Release {version: PreviousVersion})
   OPTIONAL MATCH (oldRelease)-[:dependency]->(oldDep:Artifact)
   WITH LibraryID, PreviousVersion, NewestVersion, 
        NewDeps, 
        collect(DISTINCT oldDep.id) AS OldDeps

   // Calculate added and removed dependencies
   WITH LibraryID, PreviousVersion, NewestVersion, 
        [dep IN NewDeps WHERE NOT dep IN OldDeps] AS AddedDeps, 
        [dep IN OldDeps WHERE NOT dep IN NewDeps] AS RemovedDeps,
        size([dep IN NewDeps WHERE NOT dep IN OldDeps]) AS AddedDepsCount,
        size([dep IN OldDeps WHERE NOT dep IN NewDeps]) AS RemovedDepsCount,
        CASE 
            WHEN size([dep IN NewDeps WHERE NOT dep IN OldDeps]) > 0 OR size([dep IN OldDeps WHERE NOT dep IN NewDeps]) > 0 THEN 'Changed' 
            ELSE 'No Change' 
        END AS Change,
        size([dep IN NewDeps WHERE NOT dep IN OldDeps]) - size([dep IN OldDeps WHERE NOT dep IN NewDeps]) AS NetChange

   RETURN 
       LibraryID, 
       PreviousVersion, 
       NewestVersion, 
       AddedDeps, 
       RemovedDeps, 
       AddedDepsCount, 
       RemovedDepsCount, 
       Change, 
       NetChange",
  
  "file:///all_results_2019_detailed.csv",  // Save to this path
  {batchSize: 1000}
)


// Main QUERY - 2020 Results

CALL apoc.export.csv.query(
  "MATCH (a:Artifact)-[:relationship_AR]->(release:Release)
   WHERE datetime({epochMillis: release.timestamp}).year = 2020  // Filter releases for the year 2007
   WITH DISTINCT a.id AS LibraryID
   
   // Process each library to collect versions and dependency changes
   MATCH (a:Artifact {id: LibraryID})-[:relationship_AR]->(release:Release)
   WHERE datetime({epochMillis: release.timestamp}).year = 2020  // Ensure release year filter for versions
   WITH LibraryID, release.version AS Version
   ORDER BY LibraryID, toFloat(replace(Version, '.', '')) ASC  // Use toFloat to avoid integer overflow
   WITH LibraryID, collect(Version) AS versions

   // Loop through versions to find changes between consecutive versions
   UNWIND range(0, size(versions) - 2) AS idx
   WITH LibraryID, versions[idx] AS PreviousVersion, versions[idx + 1] AS NewestVersion

   // Get dependencies for the newest version
   MATCH (a:Artifact {id: LibraryID})-[:relationship_AR]->(newRelease:Release {version: NewestVersion})
   OPTIONAL MATCH (newRelease)-[:dependency]->(newDep:Artifact)
   WITH LibraryID, PreviousVersion, NewestVersion, collect(DISTINCT newDep.id) AS NewDeps

   // Get dependencies for the previous version
   MATCH (a:Artifact {id: LibraryID})-[:relationship_AR]->(oldRelease:Release {version: PreviousVersion})
   OPTIONAL MATCH (oldRelease)-[:dependency]->(oldDep:Artifact)
   WITH LibraryID, PreviousVersion, NewestVersion, 
        NewDeps, 
        collect(DISTINCT oldDep.id) AS OldDeps

   // Calculate added and removed dependencies
   WITH LibraryID, PreviousVersion, NewestVersion, 
        [dep IN NewDeps WHERE NOT dep IN OldDeps] AS AddedDeps, 
        [dep IN OldDeps WHERE NOT dep IN NewDeps] AS RemovedDeps,
        size([dep IN NewDeps WHERE NOT dep IN OldDeps]) AS AddedDepsCount,
        size([dep IN OldDeps WHERE NOT dep IN NewDeps]) AS RemovedDepsCount,
        CASE 
            WHEN size([dep IN NewDeps WHERE NOT dep IN OldDeps]) > 0 OR size([dep IN OldDeps WHERE NOT dep IN NewDeps]) > 0 THEN 'Changed' 
            ELSE 'No Change' 
        END AS Change,
        size([dep IN NewDeps WHERE NOT dep IN OldDeps]) - size([dep IN OldDeps WHERE NOT dep IN NewDeps]) AS NetChange

   RETURN 
       LibraryID, 
       PreviousVersion, 
       NewestVersion, 
       AddedDeps, 
       RemovedDeps, 
       AddedDepsCount, 
       RemovedDepsCount, 
       Change, 
       NetChange",
  
  "file:///all_results_2020_detailed.csv",  // Save to this path
  {batchSize: 1000}
)


// Main QUERY - 2021 Results

CALL apoc.export.csv.query(
  "MATCH (a:Artifact)-[:relationship_AR]->(release:Release)
   WHERE datetime({epochMillis: release.timestamp}).year = 2021  // Filter releases for the year 2007
   WITH DISTINCT a.id AS LibraryID
   
   // Process each library to collect versions and dependency changes
   MATCH (a:Artifact {id: LibraryID})-[:relationship_AR]->(release:Release)
   WHERE datetime({epochMillis: release.timestamp}).year = 2021  // Ensure release year filter for versions
   WITH LibraryID, release.version AS Version
   ORDER BY LibraryID, toFloat(replace(Version, '.', '')) ASC  // Use toFloat to avoid integer overflow
   WITH LibraryID, collect(Version) AS versions

   // Loop through versions to find changes between consecutive versions
   UNWIND range(0, size(versions) - 2) AS idx
   WITH LibraryID, versions[idx] AS PreviousVersion, versions[idx + 1] AS NewestVersion

   // Get dependencies for the newest version
   MATCH (a:Artifact {id: LibraryID})-[:relationship_AR]->(newRelease:Release {version: NewestVersion})
   OPTIONAL MATCH (newRelease)-[:dependency]->(newDep:Artifact)
   WITH LibraryID, PreviousVersion, NewestVersion, collect(DISTINCT newDep.id) AS NewDeps

   // Get dependencies for the previous version
   MATCH (a:Artifact {id: LibraryID})-[:relationship_AR]->(oldRelease:Release {version: PreviousVersion})
   OPTIONAL MATCH (oldRelease)-[:dependency]->(oldDep:Artifact)
   WITH LibraryID, PreviousVersion, NewestVersion, 
        NewDeps, 
        collect(DISTINCT oldDep.id) AS OldDeps

   // Calculate added and removed dependencies
   WITH LibraryID, PreviousVersion, NewestVersion, 
        [dep IN NewDeps WHERE NOT dep IN OldDeps] AS AddedDeps, 
        [dep IN OldDeps WHERE NOT dep IN NewDeps] AS RemovedDeps,
        size([dep IN NewDeps WHERE NOT dep IN OldDeps]) AS AddedDepsCount,
        size([dep IN OldDeps WHERE NOT dep IN NewDeps]) AS RemovedDepsCount,
        CASE 
            WHEN size([dep IN NewDeps WHERE NOT dep IN OldDeps]) > 0 OR size([dep IN OldDeps WHERE NOT dep IN NewDeps]) > 0 THEN 'Changed' 
            ELSE 'No Change' 
        END AS Change,
        size([dep IN NewDeps WHERE NOT dep IN OldDeps]) - size([dep IN OldDeps WHERE NOT dep IN NewDeps]) AS NetChange

   RETURN 
       LibraryID, 
       PreviousVersion, 
       NewestVersion, 
       AddedDeps, 
       RemovedDeps, 
       AddedDepsCount, 
       RemovedDepsCount, 
       Change, 
       NetChange",
  
  "file:///all_results_2021_detailed.csv",  // Save to this path
  {batchSize: 1000}
)


// Main QUERY - 2022 Results

CALL apoc.export.csv.query(
  "MATCH (a:Artifact)-[:relationship_AR]->(release:Release)
   WHERE datetime({epochMillis: release.timestamp}).year = 2022  // Filter releases for the year 2007
   WITH DISTINCT a.id AS LibraryID
   
   // Process each library to collect versions and dependency changes
   MATCH (a:Artifact {id: LibraryID})-[:relationship_AR]->(release:Release)
   WHERE datetime({epochMillis: release.timestamp}).year = 2022  // Ensure release year filter for versions
   WITH LibraryID, release.version AS Version
   ORDER BY LibraryID, toFloat(replace(Version, '.', '')) ASC  // Use toFloat to avoid integer overflow
   WITH LibraryID, collect(Version) AS versions

   // Loop through versions to find changes between consecutive versions
   UNWIND range(0, size(versions) - 2) AS idx
   WITH LibraryID, versions[idx] AS PreviousVersion, versions[idx + 1] AS NewestVersion

   // Get dependencies for the newest version
   MATCH (a:Artifact {id: LibraryID})-[:relationship_AR]->(newRelease:Release {version: NewestVersion})
   OPTIONAL MATCH (newRelease)-[:dependency]->(newDep:Artifact)
   WITH LibraryID, PreviousVersion, NewestVersion, collect(DISTINCT newDep.id) AS NewDeps

   // Get dependencies for the previous version
   MATCH (a:Artifact {id: LibraryID})-[:relationship_AR]->(oldRelease:Release {version: PreviousVersion})
   OPTIONAL MATCH (oldRelease)-[:dependency]->(oldDep:Artifact)
   WITH LibraryID, PreviousVersion, NewestVersion, 
        NewDeps, 
        collect(DISTINCT oldDep.id) AS OldDeps

   // Calculate added and removed dependencies
   WITH LibraryID, PreviousVersion, NewestVersion, 
        [dep IN NewDeps WHERE NOT dep IN OldDeps] AS AddedDeps, 
        [dep IN OldDeps WHERE NOT dep IN NewDeps] AS RemovedDeps,
        size([dep IN NewDeps WHERE NOT dep IN OldDeps]) AS AddedDepsCount,
        size([dep IN OldDeps WHERE NOT dep IN NewDeps]) AS RemovedDepsCount,
        CASE 
            WHEN size([dep IN NewDeps WHERE NOT dep IN OldDeps]) > 0 OR size([dep IN OldDeps WHERE NOT dep IN NewDeps]) > 0 THEN 'Changed' 
            ELSE 'No Change' 
        END AS Change,
        size([dep IN NewDeps WHERE NOT dep IN OldDeps]) - size([dep IN OldDeps WHERE NOT dep IN NewDeps]) AS NetChange

   RETURN 
       LibraryID, 
       PreviousVersion, 
       NewestVersion, 
       AddedDeps, 
       RemovedDeps, 
       AddedDepsCount, 
       RemovedDepsCount, 
       Change, 
       NetChange",
  
  "file:///all_results_2022_detailed.csv",  // Save to this path
  {batchSize: 1000}
)


// Main QUERY - 2023 Results

CALL apoc.export.csv.query(
  "MATCH (a:Artifact)-[:relationship_AR]->(release:Release)
   WHERE datetime({epochMillis: release.timestamp}).year = 2023  // Filter releases for the year 2007
   WITH DISTINCT a.id AS LibraryID
   
   // Process each library to collect versions and dependency changes
   MATCH (a:Artifact {id: LibraryID})-[:relationship_AR]->(release:Release)
   WHERE datetime({epochMillis: release.timestamp}).year = 2023  // Ensure release year filter for versions
   WITH LibraryID, release.version AS Version
   ORDER BY LibraryID, toFloat(replace(Version, '.', '')) ASC  // Use toFloat to avoid integer overflow
   WITH LibraryID, collect(Version) AS versions

   // Loop through versions to find changes between consecutive versions
   UNWIND range(0, size(versions) - 2) AS idx
   WITH LibraryID, versions[idx] AS PreviousVersion, versions[idx + 1] AS NewestVersion

   // Get dependencies for the newest version
   MATCH (a:Artifact {id: LibraryID})-[:relationship_AR]->(newRelease:Release {version: NewestVersion})
   OPTIONAL MATCH (newRelease)-[:dependency]->(newDep:Artifact)
   WITH LibraryID, PreviousVersion, NewestVersion, collect(DISTINCT newDep.id) AS NewDeps

   // Get dependencies for the previous version
   MATCH (a:Artifact {id: LibraryID})-[:relationship_AR]->(oldRelease:Release {version: PreviousVersion})
   OPTIONAL MATCH (oldRelease)-[:dependency]->(oldDep:Artifact)
   WITH LibraryID, PreviousVersion, NewestVersion, 
        NewDeps, 
        collect(DISTINCT oldDep.id) AS OldDeps

   // Calculate added and removed dependencies
   WITH LibraryID, PreviousVersion, NewestVersion, 
        [dep IN NewDeps WHERE NOT dep IN OldDeps] AS AddedDeps, 
        [dep IN OldDeps WHERE NOT dep IN NewDeps] AS RemovedDeps,
        size([dep IN NewDeps WHERE NOT dep IN OldDeps]) AS AddedDepsCount,
        size([dep IN OldDeps WHERE NOT dep IN NewDeps]) AS RemovedDepsCount,
        CASE 
            WHEN size([dep IN NewDeps WHERE NOT dep IN OldDeps]) > 0 OR size([dep IN OldDeps WHERE NOT dep IN NewDeps]) > 0 THEN 'Changed' 
            ELSE 'No Change' 
        END AS Change,
        size([dep IN NewDeps WHERE NOT dep IN OldDeps]) - size([dep IN OldDeps WHERE NOT dep IN NewDeps]) AS NetChange

   RETURN 
       LibraryID, 
       PreviousVersion, 
       NewestVersion, 
       AddedDeps, 
       RemovedDeps, 
       AddedDepsCount, 
       RemovedDepsCount, 
       Change, 
       NetChange",
  
  "file:///all_results_2023_detailed.csv",  // Save to this path
  {batchSize: 1000}
)


// Main QUERY - 2024 Results

CALL apoc.export.csv.query(
  "MATCH (a:Artifact)-[:relationship_AR]->(release:Release)
   WHERE datetime({epochMillis: release.timestamp}).year = 2024  // Filter releases for the year 2007
   WITH DISTINCT a.id AS LibraryID
   
   // Process each library to collect versions and dependency changes
   MATCH (a:Artifact {id: LibraryID})-[:relationship_AR]->(release:Release)
   WHERE datetime({epochMillis: release.timestamp}).year = 2024  // Ensure release year filter for versions
   WITH LibraryID, release.version AS Version
   ORDER BY LibraryID, toFloat(replace(Version, '.', '')) ASC  // Use toFloat to avoid integer overflow
   WITH LibraryID, collect(Version) AS versions

   // Loop through versions to find changes between consecutive versions
   UNWIND range(0, size(versions) - 2) AS idx
   WITH LibraryID, versions[idx] AS PreviousVersion, versions[idx + 1] AS NewestVersion

   // Get dependencies for the newest version
   MATCH (a:Artifact {id: LibraryID})-[:relationship_AR]->(newRelease:Release {version: NewestVersion})
   OPTIONAL MATCH (newRelease)-[:dependency]->(newDep:Artifact)
   WITH LibraryID, PreviousVersion, NewestVersion, collect(DISTINCT newDep.id) AS NewDeps

   // Get dependencies for the previous version
   MATCH (a:Artifact {id: LibraryID})-[:relationship_AR]->(oldRelease:Release {version: PreviousVersion})
   OPTIONAL MATCH (oldRelease)-[:dependency]->(oldDep:Artifact)
   WITH LibraryID, PreviousVersion, NewestVersion, 
        NewDeps, 
        collect(DISTINCT oldDep.id) AS OldDeps

   // Calculate added and removed dependencies
   WITH LibraryID, PreviousVersion, NewestVersion, 
        [dep IN NewDeps WHERE NOT dep IN OldDeps] AS AddedDeps, 
        [dep IN OldDeps WHERE NOT dep IN NewDeps] AS RemovedDeps,
        size([dep IN NewDeps WHERE NOT dep IN OldDeps]) AS AddedDepsCount,
        size([dep IN OldDeps WHERE NOT dep IN NewDeps]) AS RemovedDepsCount,
        CASE 
            WHEN size([dep IN NewDeps WHERE NOT dep IN OldDeps]) > 0 OR size([dep IN OldDeps WHERE NOT dep IN NewDeps]) > 0 THEN 'Changed' 
            ELSE 'No Change' 
        END AS Change,
        size([dep IN NewDeps WHERE NOT dep IN OldDeps]) - size([dep IN OldDeps WHERE NOT dep IN NewDeps]) AS NetChange

   RETURN 
       LibraryID, 
       PreviousVersion, 
       NewestVersion, 
       AddedDeps, 
       RemovedDeps, 
       AddedDepsCount, 
       RemovedDepsCount, 
       Change, 
       NetChange",
  
  "file:///all_results_2024_detailed.csv",  // Save to this path
  {batchSize: 1000}
)


// MAIN QUERY 1
// This query compares dependencies between the all the versions 
// for all of the top libraries, identifying added and removed dependencies.

// Step 1: Collect all libraries and their versions
MATCH (a:Artifact)-[:relationship_AR]->(release:Release)
WITH a.id AS LibraryID, release.version AS Version
ORDER BY LibraryID, Version ASC
WITH LibraryID, collect(Version) AS versions

// Step 2: Loop through each library and its versions
UNWIND range(0, size(versions) - 2) AS idx
WITH LibraryID, versions[idx] AS PreviousVersion, versions[idx + 1] AS NewestVersion

// Match the dependencies of the newest version
MATCH (a:Artifact {id: LibraryID})-[:relationship_AR]->(newRelease:Release {version: NewestVersion})
OPTIONAL MATCH (newRelease)-[:dependency]->(newDep:Artifact)

// Match the dependencies of the previous version
MATCH (a)-[:relationship_AR]->(oldRelease:Release {version: PreviousVersion})
OPTIONAL MATCH (oldRelease)-[:dependency]->(oldDep:Artifact)

// Identify added and removed dependencies between consecutive versions
WITH LibraryID, NewestVersion, PreviousVersion, 
     collect(DISTINCT newDep.id) AS NewDeps, 
     collect(DISTINCT oldDep.id) AS OldDeps

WITH LibraryID, NewestVersion, PreviousVersion, 
     [dep IN NewDeps WHERE NOT dep IN OldDeps] AS AddedDeps, 
     [dep IN OldDeps WHERE NOT dep IN NewDeps] AS RemovedDeps

// Return results
RETURN LibraryID, PreviousVersion, NewestVersion, AddedDeps, RemovedDeps
ORDER BY LibraryID, NewestVersion;


// MAIN QUERY 2

// Step 1: Fetch the top 10 libraries based on POPULARITY_1_YEAR
MATCH (a:Artifact)-[:relationship_AR]->(r:Release)-[:addedValues]->(v:AddedValue)
WHERE v.type = 'POPULARITY_1_YEAR' AND toInteger(v.value) > 0
WITH a.id AS LibraryID
ORDER BY toInteger(v.value) DESC
LIMIT 10

// Create a list of library IDs with their labels (1 to 10)
WITH collect(LibraryID) AS LibraryIDs
UNWIND range(0, size(LibraryIDs) - 1) AS idx
WITH LibraryIDs[idx] AS LibraryID, idx + 1 AS LibraryLabel

// Step 2: Collect all versions of each library
MATCH (a:Artifact)-[:relationship_AR]->(release:Release)
WHERE a.id = LibraryID
WITH LibraryID, LibraryLabel, release.version AS Version
ORDER BY LibraryID, toInteger(replace(Version, '.', '')) ASC
WITH LibraryID, LibraryLabel, collect(Version) AS versions

// Step 3: Loop through each library and its versions
UNWIND range(0, size(versions) - 2) AS idx
WITH LibraryID, LibraryLabel, versions[idx] AS PreviousVersion, versions[idx + 1] AS NewestVersion

// Match the dependencies of the newest version
MATCH (a:Artifact {id: LibraryID})-[:relationship_AR]->(newRelease:Release {version: NewestVersion})
OPTIONAL MATCH (newRelease)-[:dependency]->(newDep:Artifact)
WITH LibraryID, LibraryLabel, PreviousVersion, NewestVersion, collect(DISTINCT newDep.id) AS NewDeps

// Match the dependencies of the previous version
MATCH (a:Artifact {id: LibraryID})-[:relationship_AR]->(oldRelease:Release {version: PreviousVersion})
OPTIONAL MATCH (oldRelease)-[:dependency]->(oldDep:Artifact)
WITH LibraryID, LibraryLabel, PreviousVersion, NewestVersion, 
     NewDeps, 
     collect(DISTINCT oldDep.id) AS OldDeps

// Calculate added and removed dependencies
WITH LibraryID, LibraryLabel, PreviousVersion, NewestVersion, 
     [dep IN NewDeps WHERE NOT dep IN OldDeps] AS AddedDeps, 
     [dep IN OldDeps WHERE NOT dep IN NewDeps] AS RemovedDeps

// Determine if there is any change in dependencies and calculate net change
WITH LibraryID, LibraryLabel, PreviousVersion, NewestVersion, 
     AddedDeps, RemovedDeps, 
     size(AddedDeps) AS AddedDepsCount, 
     size(RemovedDeps) AS RemovedDepsCount,
     CASE 
         WHEN size(AddedDeps) > 0 OR size(RemovedDeps) > 0 THEN 'Changed' 
         ELSE 'No Change' 
     END AS Change,
     size(AddedDeps) - size(RemovedDeps) AS NetChange

// Return results
RETURN 
    LibraryID, 
    LibraryLabel,
    PreviousVersion, 
    NewestVersion, 
    AddedDeps, 
    RemovedDeps,
    AddedDepsCount,
    RemovedDepsCount,
    Change,
    NetChange
ORDER BY LibraryLabel, NewestVersion;


// The query identifies the top 10 most popular libraries based on their 1-year popularity, retrieves their releases, and fetches the associated added values (e.g., popularity, freshness, vulnerabilities), providing a comprehensive overview of these libraries.

// Step 1: Fetch top 10 library IDs from Artifact nodes, not Release nodes
MATCH (a:Artifact)-[:relationship_AR]->(r:Release)-[:addedValues]->(v:AddedValue)
WHERE v.type = 'POPULARITY_1_YEAR' AND toInteger(v.value) > 0
WITH a.id AS LibraryID
ORDER BY toInteger(v.value) DESC
LIMIT 10
WITH collect(LibraryID) AS topLibraries

// Step 2: Match Artifact nodes using collected IDs
MATCH (a:Artifact)
WHERE a.id IN topLibraries
OPTIONAL MATCH (a)-[:relationship_AR]->(release:Release)
OPTIONAL MATCH (release)-[:addedValues]->(addedValue:AddedValue)
RETURN a.id AS LibraryID, 
       release.id AS ReleaseID, 
       release.version AS Version, 
       addedValue.type AS AddedValueType,
       addedValue.value AS AddedValue
ORDER BY LibraryID, ReleaseID, AddedValueType;


// This query compares dependencies between the all the versions 
// for each of the top libraries, identifying added and removed dependencies.

// Step 1: Fetch the top 10 libraries based on POPULARITY_1_YEAR
MATCH (a:Artifact)-[:relationship_AR]->(r:Release)-[:addedValues]->(v:AddedValue)
WHERE v.type = 'POPULARITY_1_YEAR' AND toInteger(v.value) > 0
WITH a.id AS LibraryID
ORDER BY toInteger(v.value) DESC
LIMIT 10

// Step 2: Collect all versions of each library
MATCH (a:Artifact)-[:relationship_AR]->(release:Release)
WHERE a.id = LibraryID
WITH a.id AS LibraryID, release.version AS Version
ORDER BY LibraryID, toInteger(replace(Version, '.', '')) ASC
WITH LibraryID, collect(Version) AS versions

// Step 3: Loop through each library and its versions
UNWIND range(0, size(versions) - 2) AS idx
WITH LibraryID, versions[idx] AS PreviousVersion, versions[idx + 1] AS NewestVersion

// Match the dependencies of the newest version
MATCH (a:Artifact {id: LibraryID})-[:relationship_AR]->(newRelease:Release {version: NewestVersion})
OPTIONAL MATCH (newRelease)-[:dependency]->(newDep:Artifact)

// Match the dependencies of the previous version
MATCH (a)-[:relationship_AR]->(oldRelease:Release {version: PreviousVersion})
OPTIONAL MATCH (oldRelease)-[:dependency]->(oldDep:Artifact)

// Identify added and removed dependencies between consecutive versions
WITH LibraryID, NewestVersion, PreviousVersion, 
     collect(DISTINCT newDep.id) AS NewDeps, 
     collect(DISTINCT oldDep.id) AS OldDeps

WITH LibraryID, NewestVersion, PreviousVersion, 
     [dep IN NewDeps WHERE NOT dep IN OldDeps] AS AddedDeps, 
     [dep IN OldDeps WHERE NOT dep IN NewDeps] AS RemovedDeps

// Return results
RETURN LibraryID, PreviousVersion, NewestVersion, AddedDeps, RemovedDeps
ORDER BY LibraryID, NewestVersion;


// This query compares dependencies between the two latest versions 
// for each of the top libraries, identifying added and removed dependencies.

// Step 1: Fetch the top 10 libraries based on POPULARITY_1_YEAR
MATCH (a:Artifact)-[:relationship_AR]->(r:Release)-[:addedValues]->(v:AddedValue)
WHERE v.type = 'POPULARITY_1_YEAR' AND toInteger(v.value) > 0
WITH a.id AS LibraryID
ORDER BY toInteger(v.value) DESC
LIMIT 10

// Step 2: For each library, get the latest two versions
MATCH (a:Artifact)-[:relationship_AR]->(release:Release)
WHERE a.id = LibraryID
WITH a.id AS LibraryID, release.version AS Version
ORDER BY toInteger(replace(Version, '.', '')) DESC
WITH LibraryID, collect(Version)[0..2] AS versions
WHERE size(versions) = 2

// Step 3: Construct the dynamic list
WITH collect([LibraryID, versions[0], versions[1]]) AS libraries

// Step 4: Use the dynamically constructed list in the next steps
UNWIND libraries AS lib

// Extract library ID, newest version, and previous version
WITH lib[0] AS LibraryID, lib[1] AS NewestVersion, lib[2] AS PreviousVersion

// Match the dependencies of the newest version
MATCH (a:Artifact {id: LibraryID})-[:relationship_AR]->(newRelease:Release {version: NewestVersion})
OPTIONAL MATCH (newRelease)-[:dependency]->(newDep:Artifact)

// Match the dependencies of the previous version
MATCH (a)-[:relationship_AR]->(oldRelease:Release {version: PreviousVersion})
OPTIONAL MATCH (oldRelease)-[:dependency]->(oldDep:Artifact)

// Identify added and removed dependencies
WITH LibraryID, 
     collect(DISTINCT newDep.id) AS NewDeps, 
     collect(DISTINCT oldDep.id) AS OldDeps
WITH LibraryID, 
     [dep IN NewDeps WHERE NOT dep IN OldDeps] AS AddedDeps, 
     [dep IN OldDeps WHERE NOT dep IN NewDeps] AS RemovedDeps

// Return results
RETURN LibraryID, AddedDeps, RemovedDeps
ORDER BY LibraryID;


// Track migrations across all versions of org.jgrapht:jgrapht-core
MATCH (a:Artifact)-[e1:relationship_AR]->(old:Release),
      (a)-[e2:relationship_AR]->(new:Release)
WHERE old.id STARTS WITH 'org.jgrapht:jgrapht-core'
  AND new.id STARTS WITH 'org.jgrapht:jgrapht-core'
  AND old.version < new.version
RETURN old.version, new.version, count(a) AS MigrationCount
ORDER BY old.version, new.version