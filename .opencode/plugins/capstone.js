/**
 * Capstone plugin for OpenCode.ai
 *
 * Registers the plugin's skills directory via the config hook so OpenCode
 * discovers the capstone skills without symlinks or manual config edits.
 * (Registration approach adapted from obra/superpowers, MIT.)
 */

import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));

export const CapstonePlugin = async () => {
  const skillsDir = path.resolve(__dirname, '../../skills');

  return {
    // Config.get() returns a cached singleton; pushing the path here makes
    // the skills visible when OpenCode lazily discovers them later.
    config: async (config) => {
      config.skills = config.skills || {};
      config.skills.paths = config.skills.paths || [];
      if (!config.skills.paths.includes(skillsDir)) {
        config.skills.paths.push(skillsDir);
      }
    },
  };
};
