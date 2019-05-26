local BuildDockerFileBase = {
  "image": "plugins/docker",
  "settings": {
    "auto_tag": true,
    "password": {
      "from_secret": "docker_hub_password"
    },
    "purge": true,
    "repo": "coreyja/rust-cache",
    "username": {
      "from_secret": "docker_hub_username"
    }
  }
};

local BuildBaseStep = BuildDockerFileBase {
  "name": "build-base-docker-image",
  "settings"+: {
    "auto_tag_suffix": "base",
    "dockerfile": "Dockerfile",
    "purge": false,
  },
  "depends_on": ["clone"],
};

local BuildCacheTypeStep(name) = BuildDockerFileBase {
  "name": "build-%s-docker-image" % name,
  "settings"+: {
    "auto_tag_suffix": name,
    "dockerfile": "cache-types/%s/Dockerfile" % name,
  },
  "depends_on": [BuildBaseStep.name],
};

local steps = [
  BuildBaseStep,
  BuildCacheTypeStep("ruby"),
  BuildCacheTypeStep("yarn"),
];

{
  "kind": "pipeline",
  "name": "default",
  "platform": {
    "os": "linux",
    "arch": "amd64",
  },
  "steps": steps
}
